import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_adapter.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/socketio/socketio_model.dart';
import 'package:flutter_appirc/socketio/socketio_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "LoungeService", enabled: true);

var _connectTimeout = Duration(seconds: 15);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);

const _timeoutForRequestsWithResponse = Duration(seconds: 10);
const _timeBetweenCheckResultForRequestsWithResponse =
    Duration(milliseconds: 100);

class LoungeBackendService extends Providable
    implements ChatInputOutputBackendService {
  final LoungePreferences _loungePreferences;
  final SocketIOManager socketIOManager;
  SocketIOService _socketIOService;

  @override
  ChatConfig chatConfig;

  @override
  ChatInitInformation chatInit;

  // lounge don't response properly to edit request
  // ignore: close_sinks
  BehaviorSubject<ChatNetworkPreferences> _editNetworkRequests =
      BehaviorSubject();

  @override
  bool get isReadyToConnect =>
      _socketIOService != null &&
      connectionState == ChatConnectionState.DISCONNECTED &&
      _loungePreferences != null &&
      _loungePreferences != LoungeConnectionPreferences.empty;

  final List<LoungeRequest> _pendingRequests = [];

  LoungeBackendService(this.socketIOManager, this._loungePreferences) {
    addDisposable(subject: _connectionStateController);
    addDisposable(subject: _editNetworkRequests);
  }

  Future init() async {
    _logger.d(() => "init started");

    var host = _loungePreferences.connectionPreferences.host;
    _socketIOService = SocketIOService(socketIOManager, host);

    await _socketIOService.init();

    addDisposable(
        disposable: _createEventListenerDisposable(
            _socketIOService, SocketIO.DISCONNECT, (_) {
      _logger.d(() => "on Disconnect");
      _connectionStateController.add(ChatConnectionState.DISCONNECTED);
    }));

    _logger.d(() => "init finished");
  }

  bool get isConnected => connectionState == ChatConnectionState.CONNECTED;

  // ignore: close_sinks
  BehaviorSubject<ChatConnectionState> _connectionStateController =
      BehaviorSubject(seedValue: ChatConnectionState.DISCONNECTED);

  Stream<ChatConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  ChatConnectionState get connectionState => _connectionStateController.value;

  Future<RequestResult<ConnectResult>> tryConnectWithDifferentPreferences(
      LoungePreferences preferences) async {
    SocketIOService socketIOService;

    ConnectResult connectResult;
    try {
      socketIOService = SocketIOService(
          socketIOManager, preferences.connectionPreferences.host);
      await socketIOService.init();
      connectResult = await _connect(preferences, socketIOService);
    } catch (e) {
      _logger.d(() => "error during tryConnectWithDifferentPreferences = $e");
    } finally {
      if (socketIOService != null && chatConfig != null) {
        socketIOService.disconnect();
      }
    }

    return RequestResult(true, connectResult);
  }

  @override
  Future<RequestResult<ConnectResult>> connectChat() async {
    assert(_loungePreferences != LoungeConnectionPreferences.empty);

    _connectionStateController.add(ChatConnectionState.CONNECTING);

    ConnectResult connectResult =
        await _connect(_loungePreferences, _socketIOService);

    if (connectResult.config != null) {
      this.chatConfig = connectResult.config;
      this.chatInit = connectResult.chatInit;
      _connectionStateController.add(ChatConnectionState.CONNECTED);
    } else {
      _connectionStateController.add(ChatConnectionState.DISCONNECTED);
    }

    _logger.d(() => "connectChat = $connectResult chatConfig = $chatConfig");

    return RequestResult(true, connectResult);
  }

  Disposable listenForConfiguration(
          Function(ConfigurationLoungeResponseBody) listener) =>
      _listenForConfiguration(_socketIOService, listener);

  Disposable listenForCommands(Function(List<String>) listener) =>
      _listenForCommands(_socketIOService, listener);

  Disposable listenForAuthorized(VoidCallback listener) =>
      _listenForAuthorized(_socketIOService, listener);

  Disposable createEventListenerDisposable(
          String eventName, Function(dynamic raw) listener) =>
      _createEventListenerDisposable(_socketIOService, eventName, listener);

  @override
  Future<RequestResult<bool>> disconnectChat(
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    disconnect();
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> editNetworkChannelTopic(
      Network network, NetworkChannel channel, String newTopic,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, "/topic $newTopic");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<Network>> editNetworkSettings(
      Network network, ChatNetworkPreferences networkPreferences,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }

    // todo: open ticket for lounge
    // if you change nickname to registered nickname on Freenode
    // then you should write additional query to identify

    var userPreferences =
        networkPreferences.networkConnectionPreferences.userPreferences;
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.networkEdit,
        body: toNetworkEditLoungeRequestBody(
            network.remoteId, userPreferences, serverPreferences));

    // important to put request before send it
    _editNetworkRequests.add(networkPreferences);

    _sendRequest(request, isNeedAddRequestToPending: false);

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> enableNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/connect");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> disableNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/disconnect");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<List<NetworkChannelUser>>> requestNetworkChannelUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }

    _sendRequest(
        LoungeJsonRequest(
            name: LoungeRequestEventNames.names,
            body: NamesLoungeRequestBody.name(target: channel.remoteId)),
        isNeedAddRequestToPending: false);

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkChannelUser>> printUserInfo(
      Network network, NetworkChannel channel, String userNick,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, "/whois $userNick");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkWithState>> joinNetwork(
      ChatNetworkPreferences networkPreferences,
      {bool waitForResult = false}) async {
    var userPreferences =
        networkPreferences.networkConnectionPreferences.userPreferences;
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var channelsWithoutPassword = networkPreferences.channelsWithoutPassword;
    var channelNames = channelsWithoutPassword.map((channel) => channel.name);
    String join = channelNames.join(LoungeConstants.channelsNamesSeparator);
    var request = JoinNetworkLoungeRequest(
        networkPreferences,
        toNetworkNewLoungeRequestBody(
            userPreferences, join, serverPreferences));

    var result;
    Disposable networkListener;
    networkListener = listenForNetworkJoin((networkWithState) async {
      var networkFromResult = networkWithState.network;

      if (networkFromResult.name == serverPreferences.name) {
        var channelsWithPassword = networkPreferences.channelsWithPassword;

        _logger
            .d(() => "joinNetwork channelsWithPassword $channelsWithPassword");

        if (channelsWithPassword.isNotEmpty) {
          // it is bug in the lounge.
          // We should wait some time after join network to start send requests to network
          // Lounge don't respond with error, it is just don't execute requests
          // todo: open request for lounge server to fix this issue
          await Future.delayed(Duration(seconds: 5));

          for (var channelPreferences in channelsWithPassword) {
            var joinChannelResult = await joinNetworkChannel(
                networkWithState.network, channelPreferences,
                waitForResult: true);
            _logger.d(() => "joinNetwork joinChannelResult $joinChannelResult");

            if (joinChannelResult.result != null) {
              var channel = joinChannelResult.result.channel;
              _logger.d(() =>
                  "joinNetwork channelPreferences $channelPreferences result = $channel");
              assert(channel != null);
              networkFromResult.channels.add(channel);
            }
          }
        }

        result = networkWithState;
        networkListener.dispose();
      }
    });
    _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<NetworkWithState>(() => result);
    } else {
      return RequestResult.name(isSentSuccessfully: true, result: null);
    }
  }

  Future<RequestResult<T>> _doWaitForResult<T>(
      T Function() resultExtractor) async {
    RequestResult<T> result;

    Future.delayed(_timeoutForRequestsWithResponse, () {
      if (result == null) {
        _logger.d(() => "_doWaitForResult timeout");
        result = RequestResult(true, null);
      }
    });

    while (result == null) {
      await Future.delayed(_timeBetweenCheckResultForRequestsWithResponse);
      T extracted = resultExtractor();
      if (extracted != null) {
        _logger.d(() => "_doWaitForResult extracted = $extracted");
        result = RequestResult(true, extracted);
      }
    }

    return result;
  }

  @override
  Future<RequestResult<NetworkChannelWithState>> joinNetworkChannel(
      Network network, ChatNetworkChannelPreferences preferences,
      {bool waitForResult = false}) async {
    _logger.d(
        () => "joinNetworkChannel $preferences waitForResult $waitForResult");

    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: JoinChannelInputLoungeRequestBody(
            preferences, network.lobbyChannel.remoteId));

    var result;
    Disposable channelListener;
    channelListener =
        listenForNetworkChannelJoin(network, (channelWithState) async {
      var isForRequest = channelWithState.channel.name == preferences.name;
      _logger.d(() =>
          "joinNetworkChannel listenForNetworkChannelJoin $channelWithState isForRequest= $isForRequest");
      if (isForRequest) {
        result = channelWithState;
        channelListener.dispose();
      }
    });
    _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<NetworkChannelWithState>(() => result);
    } else {
      return RequestResult.name(isSentSuccessfully: true, result: null);
    }
  }

  @override
  Future<RequestResult<NetworkChannelWithState>> openDirectMessagesChannel(
      Network network, NetworkChannel channel, String nick,
      {bool waitForResult = false}) async {
    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: InputLoungeRequestBody(
            target: channel.remoteId, content: "/query $nick"));

    var result;
    Disposable channelListener;
    channelListener =
        listenForNetworkChannelJoin(network, (channelWithState) async {
      result = channelWithState;
      channelListener.dispose();
    });
    _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<NetworkChannelWithState>(() => result);
    } else {
      return RequestResult.name(isSentSuccessfully: true, result: null);
    }
  }

  @override
  Future<RequestResult<bool>> leaveNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/quit");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> leaveNetworkChannel(
      Network network, NetworkChannel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, "/close");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Disposable listenForMessages(Network network, NetworkChannel channel,
      NetworkChannelMessageListener listener) {
    var disposable = CompositeDisposable([]);
    disposable
        .add(createEventListenerDisposable(LoungeResponseEventNames.msg, (raw) {
      var data = MessageLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var message = toChatMessage(channel, data.msg);
        _logger.d(() => "onNewMessage for {$data.chan}  $data");
        var type = detectRegularMessageType(data.msg.type);
        if (type == RegularMessageType.WHO_IS) {
          var whoIsSpecialBody = toSpecialMessageWhoIs(data.msg.whois);
          listener(SpecialMessage.name(
              channelRemoteId: data.chan,
              data: whoIsSpecialBody,
              specialType: SpecialMessageType.WHO_IS,
              date: DateTime.now()));
        } else {
          listener(message);
        }
      }
    }));

    disposable.add(createEventListenerDisposable(
        LoungeResponseEventNames.msgSpecial, (raw) {
      MessageSpecialLoungeResponseBody data =
          MessageSpecialLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var specialMessages = toSpecialMessages(channel, data);

        specialMessages.forEach((specialMessage) {
          listener(specialMessage);
        });
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkChannelJoin(
      Network network, NetworkChannelListener listener) {
    _logger.d(() => "listenForNetworkChannelJoin $network");

    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable(LoungeResponseEventNames.join, (raw) {
      var parsed = JoinLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "listenForNetworkChannelJoin "
          "parsed $parsed network.remoteId = $network.remoteId");
      if (parsed.network == network.remoteId) {
        LoungeJsonRequest<JoinChannelInputLoungeRequestBody> request =
            _pendingRequests.firstWhere((request) {
          if (request is LoungeJsonRequest<JoinChannelInputLoungeRequestBody>) {
            LoungeJsonRequest<JoinChannelInputLoungeRequestBody> joinRequest =
                request;
            if (joinRequest != null) {
              if (joinRequest.body.preferences.name == parsed.chan.name) {
                return true;
              }
            } else {
              return false;
            }

            return false;
          } else {
            return false;
          }
        }, orElse: () => null);

        var preferences;

        if (request != null) {
          preferences = ChatNetworkChannelPreferences.name(
              localId: request.body.preferences.localId,
              name: parsed.chan.name,
              password: request.body.preferences.password);
        } else {
          preferences = ChatNetworkChannelPreferences.name(
              name: parsed.chan.name, password: "");
        }

        var loungeChannel = parsed.chan;

        var channelWithState = toNetworkChannelWithState(loungeChannel);

        channelWithState.channel.channelPreferences = preferences;


        listener(channelWithState);
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkChannelLeave(
      Network network, NetworkChannel channel, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.part), (raw) {
      var parsed = PartLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.chan == channel.remoteId) {
        listener();
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkChannelState(
      Network network,
      NetworkChannel channel,
      NetworkChannelState Function() currentStateExtractor,
      NetworkChannelStateListener listener) {
    var disposable = CompositeDisposable([]);
    disposable
        .add(createEventListenerDisposable(LoungeResponseEventNames.msg, (raw) {
      var data = MessageLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        if (data.unread != null) {
          var channelState = currentStateExtractor();
          channelState.unreadCount = data.unread;
          listener(channelState);
        }
      }
    }));

    disposable.add(
        createEventListenerDisposable(LoungeResponseEventNames.topic, (raw) {
      var data = TopicLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var channelState = currentStateExtractor();
        channelState.topic = data.topic;
        listener(channelState);
      }
    }));

    disposable.add(createEventListenerDisposable(
        LoungeResponseEventNames.channelState, (raw) {
      var data =
          ChannelStateLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var channelState = currentStateExtractor();
        if (data.state == LoungeConstants.CHANNEL_STATE_CONNECTED) {
          channelState.connected = true;
        } else {
          channelState.connected = false;
        }

        listener(channelState);
//        var message = toIRCMessage(data.msg);
//        listener(message);
      }
    }));

    return disposable;
  }

  Disposable listenForNetworkChannelUsers(
      Network network, NetworkChannel channel, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.users), (raw) {
      var parsed = UsersLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.chan == channel.remoteId) {
        listener();
      }
    }));

    return disposable;
  }


  @override
  Disposable listenForNetworkJoin(NetworkListener listener) {
    var disposable = CompositeDisposable([]);

    disposable.add(
        createEventListenerDisposable(LoungeResponseEventNames.network, (raw) {
      var parsed = NetworksLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "listenForNetworkJoin parsed = $parsed");

      for (var loungeNetwork in parsed.networks) {
        // todo: check existed networks

        JoinNetworkLoungeRequest request =
            _pendingRequests.firstWhere((request) {
          var loungeJsonRequest = request as JoinNetworkLoungeRequest;
          if (loungeJsonRequest != null) {
            if (loungeNetwork.name == loungeJsonRequest.body.name) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        }, orElse: () => null);

        var connectionPreferences =
            request.networkPreferences.networkConnectionPreferences;

        // when requested nick is not available and server give new nick
        var nick = loungeNetwork.nick;
        connectionPreferences.userPreferences.nickname = nick;

        NetworkWithState networkWithState = toNetworkWithState(loungeNetwork);

        networkWithState.network.localId = request.networkPreferences.localId;

        networkWithState.network.channels.forEach((channel) {
          var networkChannelPreferences = request.networkPreferences.channels
              .firstWhere((channelPreferences) {
            return channel.name == channelPreferences.name;
          }, orElse: () => null);

          if (networkChannelPreferences != null) {
            channel.localId = networkChannelPreferences.localId;
          }
        });

        networkWithState.network.connectionPreferences = connectionPreferences;

        listener(networkWithState);
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkLeave(Network network, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.quit), (raw) {
      var parsed = QuitLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        listener();
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForMessagePreviews(Network network, NetworkChannel channel,
      NetworkChannelMessagePreviewListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (LoungeResponseEventNames.msgPreview), (raw) {
      var parsed =
          MsgPreviewLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.chan == channel.remoteId) {
        listener(
            PreviewForMessage(parsed.id, toMessagePreview(parsed.preview)));
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkEdit(
      Network network, NetworkConnectionListener listener) {
    return StreamSubscriptionDisposable(_editNetworkRequests
        .listen((ChatNetworkPreferences networkPreferences) {
      if (network.connectionPreferences.localId == networkPreferences.localId) {
        listener(networkPreferences);
      }
    }));
  }

  Disposable listenForNetworkState(
      Network network,
      NetworkState Function() currentStateExtractor,
      NetworkStateListener listener) {
    var disposable = CompositeDisposable([]);

    disposable.add(StreamSubscriptionDisposable(_editNetworkRequests
        .listen((ChatNetworkPreferences networkPreferences) {
      if (network.connectionPreferences.localId == networkPreferences.localId) {
        var currentState = currentStateExtractor();
        currentState.name = networkPreferences
            .networkConnectionPreferences.serverPreferences.name;
        listener(currentState);
      }
    })));

    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.nick), (raw) {
      var parsed = NickLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        var currentState = currentStateExtractor();
        currentState.nick = parsed.nick;
        listener(currentState);
      }
    }));

    disposable.add(createEventListenerDisposable(
        (LoungeResponseEventNames.networkOptions), (raw) {
      var parsed =
          NetworkOptionsLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        // nothing to change right now
        var currentState = currentStateExtractor();
        listener(currentState);
      }
    }));

    disposable.add(createEventListenerDisposable(
        (LoungeResponseEventNames.networkStatus), (raw) {
      var parsed =
          NetworkStatusLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        var currentState = currentStateExtractor();
        var newState = toNetworkState(parsed, currentState.nick, network.name);
        listener(newState);
      }
    }));

    return disposable;
  }

  @override
  Future<RequestResult<bool>> onOpenNetworkChannel(
      Network network, NetworkChannel channel) async {
    _sendRequest(
        LoungeRawRequest(
            name: LoungeRequestEventNames.open, body: [channel.remoteId]),
        isNeedAddRequestToPending: false);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }


  @override
  Future<RequestResult<bool>> onNewDevicePushToken(String newToken, {bool
  waitForResult = false}) async {
    _sendRequest(
        LoungeJsonRequest(
            name: LoungeRequestEventNames.pushToken, body:
        PushTokenLoungeRequestBody(token: newToken)),
        isNeedAddRequestToPending: false);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
      Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/list");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<RegularMessage>> printNetworkChannelBannedUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, "/banlist");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/ignorelist");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<RegularMessage>> sendNetworkChannelRawMessage(
      Network network, NetworkChannel channel, String rawMessage,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, rawMessage);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Disposable listenForNetworkChannelNames(Network network,
      NetworkChannel channel, Function(List<NetworkChannelUser>) listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.names), (raw) {
      var parsed = NamesLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "listenForNetworkChannelUsers $parsed for $channel");

      if (parsed.id == channel.remoteId) {
        listener(parsed.users
            .map((loungeUser) => toNetworkChannelUser(loungeUser))
            .toList());
      }
    }));

    return disposable;

//  void _onUsersResponse(raw) {
//    var parsed = UsersLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _usersController.sink.add(parsed);
//  }
  }



  _sendRequest(LoungeRequest request,
      {@required bool isNeedAddRequestToPending}) async {
    if (isNeedAddRequestToPending) {
      _pendingRequests.add(request);
    }

    _logger.d(() => "_sendCommand $request");
    return await _socketIOService.emit(request);
  }

//
//  Future<K> _sendRequestWithResult<T extends LoungeRequest, K>(
//      {@required T request,
//      String resultEventName,
//      @required K resultParser(dynamic),
//      Duration timeout = _timeoutForRequestsWithResponse}) async {
//    _logger.d(() => "_sendCommandWithResult start $request"
//        " resultEventName $resultEventName"
//        " requestWithResultInProgress = $requestWithResultInProgress");
//
//    var timeout = false;
//
//    // setup timeout
//    Future.delayed(_timeoutForRequestsWithResponse, () {
//      timeout = true;
//    });
//
//    // avoid several requests with result in one time
//    while (requestWithResultInProgress && !timeout) {
//      await Future.delayed(_timeBetweenCheckAnotherRequestInProgress, () {});
//    }
//    var resultRaw;
//
//    if (!timeout) {
//      var resultHandler = (raw) {
//        _logger.d(() => "resultHandler $raw");
//        resultRaw = raw;
//      };
//
//      _socketIOService.on(resultEventName, resultHandler);
//
//      await _socketIOService.emit(request);
//
//      // wait for response or timeout
//      while (timeout != true && resultRaw == null) {
//        await Future.delayed(
//            _timeBetweenCheckResultForRequestsWithResponse, () {});
//      }
//
//      _socketIOService.off(resultEventName, resultHandler);
//    }
//
//    if (timeout == true) {
//      throw RequestWithResultTimeoutLoungeException(request);
//    } else {
//      return resultParser(resultRaw);
//    }
//  }

  disconnect() async {
    var result;

    result = await _socketIOService.disconnect();
    return result;
  }

  @override
  void dispose() {
    super.dispose();

    if (connectionState == ChatConnectionState.CONNECTED) {
      disconnect();
    }
  }

//  sendSettingsGetRequest() async =>
//      await _sendRequest(LoungeRawRequest(name: "setting:get"));

  void _sendInputRequest(
      Network network, NetworkChannel channel, String message) {
    _sendRequest(
        LoungeJsonRequest(
            name: LoungeRequestEventNames.input,
            body: InputLoungeRequestBody(
                target: channel.remoteId, content: message)),
        isNeedAddRequestToPending: false);
  }

}

ChatConnectionState mapState(SocketConnectionState socketState) {
  switch (socketState) {
    case SocketConnectionState.CONNECTED:
      return ChatConnectionState.CONNECTED;
      break;
    case SocketConnectionState.DISCONNECTED:
      return ChatConnectionState.DISCONNECTED;
      break;
    case SocketConnectionState.CONNECTING:
      return ChatConnectionState.CONNECTING;
      break;
  }
  throw Exception("invalid state $socketState");
}

Disposable _listenForConfiguration(SocketIOService _socketIOService,
    Function(ConfigurationLoungeResponseBody) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (LoungeResponseEventNames.configuration), (raw) {
    var parsed =
        ConfigurationLoungeResponseBody.fromJson(_preProcessRawData(raw));

    listener(parsed);
  }));

  return disposable;
}

Disposable _listenForAuth(
    SocketIOService _socketIOService, BooleanCallback listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (LoungeResponseEventNames.auth), (raw) {
    _logger.d(() => "_listenForAuth = $raw}");
    var parsed = AuthLoungeResponseBody.fromJson(_preProcessRawData(raw));
    listener(parsed.success);
  }));

  return disposable;
}

Disposable _listenForCommands(
    SocketIOService _socketIOService, Function(List<String>) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (LoungeResponseEventNames.commands), (raw) {
    var iterable = (raw as Iterable);

    var commands = List<String>();

    iterable.forEach((obj) {
      commands.add(obj.toString());
    });

    listener(commands);
  }));

  return disposable;
}

Disposable _listenForAuthorized(
    SocketIOService _socketIOService, VoidCallback listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (LoungeResponseEventNames.authorized), (raw) {
    _logger.d(() => "_listenForAuthorized = $raw}");
    listener();
  }));

  return disposable;
}

Disposable _listenForInit(SocketIOService _socketIOService,
    Function(ChatInitInformation init) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (LoungeResponseEventNames.init), (raw) {
    _logger.d(() => "_listenForInit = $raw}");
    var parsed = InitLoungeResponseBody.fromJson(_preProcessRawData(raw));

    listener(toChatInit(parsed));
  }));

  return disposable;
}

Disposable _createEventListenerDisposable(SocketIOService _socketIOService,
    String eventName, Function(dynamic raw) listener) {
  _socketIOService.on(eventName, listener);
  return CustomDisposable(() => _socketIOService.off(eventName, listener));
}

dynamic _preProcessRawData(raw, {bool isJsonData = true}) {
  // Hack for strange bug on ios
  // Flutter app throw exception which is not possible to catch
  // if use raw data without re-encoding
  // TODO: remove when bug will be fixed in socketio/json libraries
  var newRaw = raw;
  if (isJsonData && Platform.isIOS) {
    if (raw is Map) {
      var jsonData = json.encode(raw);
      newRaw = json.decode(jsonData);
    }
  }

  _logger.i(() => "_preProcessRawData json = $isJsonData converted $newRaw");
  return newRaw;
}

Future<ConnectResult> _connect(
    LoungePreferences preferences, SocketIOService socketIOService) async {
  _logger.d(() => "start connect to $preferences "
      "URI = ${socketIOService.uri}");

  ConnectResult result = ConnectResult();

  var disposable = CompositeDisposable([]);

  ConfigurationLoungeResponseBody loungeConfig;
  List<String> loungeCommands;
  bool authorizedReceived = false;
  bool authResponse;

  disposable.add(_listenForConfiguration(
      socketIOService, (result) => loungeConfig = result));
  disposable.add(
      _listenForAuthorized(socketIOService, () => authorizedReceived = true));
  disposable.add(
      _listenForAuth(socketIOService, (success) => authResponse = success));
  disposable.add(_listenForInit(
      socketIOService, (initResponse) => result.chatInit = initResponse));
  disposable.add(
      _listenForCommands(socketIOService, (result) => loungeCommands = result));

  Future.delayed(_connectTimeout, () {
    if (result.config != null || result.isFailAuthResponseReceived) {
      result.isTimeout = true;
    }
  });

  var connectErrorListener = (data) {
    _logger.d(() => "_connect connectErrorListener = $data");
    result.isSocketConnected = false;
    result.error = data;
  };

  socketIOService.onConnectError(connectErrorListener);
  disposable.add(CustomDisposable(() {
    socketIOService.offConnectError(connectErrorListener);
  }));

  result.isSocketConnected = true;

  await socketIOService.connect();

  _logger.d(() => "_connect socketConnected = ${result.isSocketConnected}");
  var authPreferences = preferences.authPreferences;

  bool authPreferencesExist =
      authPreferences != null && authPreferences != LoungeAuthPreferences.empty;
  bool authorizedResponseReceived = false;

  if (result.isSocketConnected) {

    bool isNeedWait;
    do {
      await Future.delayed(_timeBetweenCheckingConnectionResponse);

      authorizedResponseReceived = (loungeCommands != null &&
          loungeConfig != null &&
          result.chatInit != null &&
          authorizedReceived != false);
      result.isPrivateModeResponseReceived = authResponse != null || result
          .isAuthRequestSent;

      if (result.isPrivateModeResponseReceived &&
          !result.isAuthRequestSent &&
          authPreferencesExist) {
        var authRequest = LoungeJsonRequest(
            name: LoungeRequestEventNames.auth,
            body: AuthLoungeRequestBody(
              authPreferences.username,
              authPreferences.password,
            ));

        authResponse = null;
        socketIOService.emit(authRequest);
        result.isAuthRequestSent = true;
        _logger.d(() => "_connect send auth = $authRequest");
      }

      result.isFailAuthResponseReceived =
          authResponse != null ? authResponse == false : false;


      isNeedWait = !result.isTimeout;
      isNeedWait &= !result.isFailAuthResponseReceived;
      isNeedWait &= result.error == null;
      isNeedWait &= !authorizedResponseReceived;

//      var isWaitForAuthResponse =  (result.isPrivateModeResponseReceived &&
//          result.isAuthRequestSent && !result.isFailAuthResponseReceived && !authorizedResponseReceived);
//
//      if(!isWaitForAuthResponse) {
//        isNeedWait &= !authorizedResponseReceived;
//      }


    } while (isNeedWait);
  }


  _logger.d(() => "_connect end wait "
      "authorizedResponseReceived = $authorizedResponseReceived "
      ".isTimeout = ${result.isTimeout} "
      ".isPrivateModeResponseReceived = ${result
      .isPrivateModeResponseReceived} "
      ".isAuthRequestSent = ${result.isAuthRequestSent} "
      ".error = ${result.error}"

  );

  disposable.dispose();

  var configReceived = loungeConfig != null;
  var commandsReceived = loungeCommands != null;
  var chatInitReceived = result.chatInit != null;

  _logger.d(() => "_connect result = $result configReceived = $configReceived"
      " commandsReceived = $commandsReceived authorizedReceived = $authorizedReceived");

  if (authorizedResponseReceived) {
    result.config = toChatConfig(loungeConfig, loungeCommands);
  } else {
    if (authorizedReceived ||
        configReceived ||
        commandsReceived ||
        chatInitReceived) {
      throw InvalidConnectionResponseException(preferences, authorizedReceived,
          configReceived, commandsReceived, chatInitReceived);
    }
  }

  return result;
}
