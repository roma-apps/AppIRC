import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/manager.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_socketio_adapter.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/disposable/async_disposable.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/irc/irc_commands_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/lounge/upload/lounge_upload_file_helper.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/socketio/socketio_service.dart';
import 'package:flutter_appirc/url/url_finder.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "lounge_backend_service.dart", enabled: true);

var _connectTimeout = Duration(seconds: 15);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);

const _timeoutForRequestsWithResponse = Duration(seconds: 10);
const _timeBetweenCheckResultForRequestsWithResponse =
    Duration(milliseconds: 100);

class LoungeBackendService extends Providable implements ChatBackendService {
  final LoungePreferences _loungePreferences;
  final SocketIOManager socketIOManager;
  SocketIOService _socketIOService;

  Stream<bool> get chatConfigExistStream =>
      chatConfigStream.map((chatConfig) => chatConfig != null);

  bool get isConnected => connectionState == ChatConnectionState.connected;

  Stream<bool> get isConnectedStream => connectionStateStream
      .map((state) => state == ChatConnectionState.connected)
      .distinct();

  // ignore: close_sinks
  BehaviorSubject<ChatConnectionState> _connectionStateSubject =
      BehaviorSubject(seedValue: ChatConnectionState.disconnected);

  Stream<ChatConnectionState> get connectionStateStream =>
      _connectionStateSubject.stream.distinct();

  ChatConnectionState get connectionState => _connectionStateSubject.value;

  // ignore: close_sinks
  BehaviorSubject<ChatConfig> _chatConfigSubject = BehaviorSubject();

  Stream<ChatConfig> get chatConfigStream => _chatConfigSubject.stream;

  @override
  ChatConfig get chatConfig => _chatConfigSubject.value;

  @override
  ChatInitInformation chatInit;

  // ignore: close_sinks
  BehaviorSubject<bool> _signOutSubject = BehaviorSubject();

  // lounge don't response properly to edit request
  // ignore: close_sinks
  BehaviorSubject<NetworkPreferences> _editNetworkRequests = BehaviorSubject();

  @override
  bool get isReadyToConnect =>
      _socketIOService != null &&
      connectionState == ChatConnectionState.disconnected &&
      _loungePreferences != null &&
      _loungePreferences != LoungeConnectionPreferences.empty;

  // Lounge API don't return all information required by the app
  // So, in some cases we should store original request to use it in response
  // handler
  // For example, when lounge in public mode  we should save original
  // network/channel join request to save password which doesn't exist in
  // response
  final List<LoungeRequest> _pendingRequests = [];

  LoungeBackendService(this.socketIOManager, this._loungePreferences) {
    addDisposable(subject: _signOutSubject);
    addDisposable(subject: _connectionStateSubject);
    addDisposable(subject: _editNetworkRequests);
    addDisposable(subject: _messageTogglePreviewSubject);
    addDisposable(subject: _chatConfigSubject);
  }

  Future init() async {
    _logger.d(() => "init started");

    var host = _loungePreferences.connectionPreferences.host;
    _socketIOService = SocketIOService(socketIOManager, host);

    await _socketIOService.init();

    addDisposable(streamSubscription:
        _socketIOService.connectionStateStream.listen((socketState) {
      var newBackendState = mapConnectionState(socketState);
      _logger.d(() => "newState socketState $socketState "
          " newBackendState $newBackendState");
      _connectionStateSubject.add(newBackendState);
    }));
    _logger.d(() => "init finished");
  }

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
    _logger.d(() => "connectChat _loungePreferences $_loungePreferences");

    ConnectResult connectResult =
        await _connect(_loungePreferences, _socketIOService);

    if (connectResult.config != null) {
      this._chatConfigSubject.add(connectResult.config);
      this.chatInit = connectResult.chatInit;

      // socket io callback very slow
      _connectionStateSubject.add(ChatConnectionState.connected);
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
      throw NotImplementedYetLoungeException();
    }
    disconnect();
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> editChannelTopic(
      Network network, Channel channel, String newTopic,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, channel, TopicIRCCommand.name(newTopic: newTopic).asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<Network>> editNetworkSettings(
      Network network, NetworkPreferences networkPreferences,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    // todo: open ticket for lounge
    // if you change nickname to registered nickname on Freenode
    // then you should write additional query to identify user with password
    // Lounge API should send this request once new settings arrived
    var userPreferences =
        networkPreferences.networkConnectionPreferences.userPreferences;
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var request = toNetworkEditLoungeRequestBody(
        network.remoteId, userPreferences, serverPreferences);

    // important to put request before send it
    _editNetworkRequests.add(networkPreferences);

    _sendRequest(request, isNeedAddRequestToPending: false);

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> enableNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, ConnectIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> disableNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, DisconnectIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<List<ChannelUser>>> requestChannelUsers(
      Network network, Channel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    var request = NamesLoungeJsonRequest.name(target: channel.remoteId);
    _sendRequest(request, isNeedAddRequestToPending: false);

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<ChannelUser>> requestUserInfo(
      Network network, Channel channel, String userNick,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, channel, WhoIsIRCCommand.name(userNick: userNick).asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkWithState>> joinNetwork(
      NetworkPreferences networkPreferences,
      {bool waitForResult = false}) async {
    var serverPreferences =
        networkPreferences.networkConnectionPreferences.serverPreferences;

    var channelsWithoutPassword = networkPreferences.channelsWithoutPassword;
    var channelNames = channelsWithoutPassword.map((channel) => channel.name);
    String join = channelNames.join(LoungeConstants.channelsNamesSeparator);
    var request = ChatNetworkNewLoungeJsonRequest.name(
        networkPreferences: networkPreferences, join: join);

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
          // We should wait some time after join network
          // to start send requests to network
          // Lounge don't respond with error, it is just don't execute requests
          // It looks like bug exist only in public mode
          // Lounge doesn't execute request if network not created/connected
          // Lounge should send event when network is ready to receive commands
          // Also lounge should return error if something wrong
          // todo: open request for lounge server to fix this issue
          await Future.delayed(Duration(seconds: 5));

          for (var channelPreferences in channelsWithPassword) {
            var joinChannelResult = await joinChannel(
                networkWithState.network, channelPreferences,
                waitForResult: true);
            _logger.d(() => "joinNetwork joinChannelResult $joinChannelResult");

            if (joinChannelResult.result != null) {
              var channel = joinChannelResult.result.channel;
              _logger
                  .d(() => "joinNetwork channelPreferences $channelPreferences "
                      "result = $channel");
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
  Future<RequestResult<ChannelWithState>> joinChannel(
      Network network, ChannelPreferences preferences,
      {bool waitForResult = false}) async {
    _logger.d(() => "joinChannel $preferences waitForResult $waitForResult");

    var request = ChatJoinChannelInputLoungeJsonRequest.name(
        preferences, network.lobbyChannel.remoteId);

    var result;
    Disposable channelListener;
    channelListener = listenForChannelJoin(network, (channelWithState) async {
      var isForRequest = channelWithState.channel.name == preferences.name;
      _logger.d(() => "joinChannel listenForChannelJoin $channelWithState "
          "isForRequest= $isForRequest");
      if (isForRequest) {
        result = channelWithState;
        channelListener.dispose();
      }
    });
    _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<ChannelWithState>(() => result);
    } else {
      return RequestResult.name(isSentSuccessfully: true, result: null);
    }
  }

  @override
  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel(
      Network network, Channel channel, String nick,
      {bool waitForResult = false}) async {
    var request = InputLoungeJsonRequest.name(
        target: channel.remoteId, // private channel name is equal to nickname
        text: JoinIRCCommand.name(channelName: nick).asRawString);

    var result;
    Disposable channelListener;
    channelListener = listenForChannelJoin(network, (channelWithState) async {
      result = channelWithState;
      channelListener.dispose();
    });
    _sendRequest(request, isNeedAddRequestToPending: true);

    if (waitForResult) {
      return await _doWaitForResult<ChannelWithState>(() => result);
    } else {
      return RequestResult.name(isSentSuccessfully: true, result: null);
    }
  }

  @override
  Future<RequestResult<bool>> leaveNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, QuitIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> leaveChannel(Network network, Channel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(network, channel, CloseIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Disposable listenForMessages(
      Network network, Channel channel, ChannelMessageListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable(MsgLoungeResponseBody.eventName, (raw) {
      var data = MsgLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        toChatMessage(channel, data.msg).then((message) {
          _logger.d(() => "onNewMessage for {$data.chan}  $data");
          var type = detectRegularMessageType(data.msg.type);
          if (type == RegularMessageType.whoIs) {
            // lounge send whois message as regular
            // but actually lounge client display it as special
            _toWhoIsSpecialMessage(data).then((message) {
              listener(MessagesForChannel(channel, <ChatMessage>[message]));
            });
          } else {
            listener(MessagesForChannel(channel, <ChatMessage>[message]));
          }
        });
      }
    }));

    disposable.add(createEventListenerDisposable(
        MsgSpecialLoungeResponseBody.eventName, (raw) {
      MsgSpecialLoungeResponseBody data =
          MsgSpecialLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        toSpecialMessages(channel, data).then((specialMessages) {
          listener(MessagesForChannel(channel, specialMessages));
        });
      }
    }));

    disposable.add(listenForLoadMore(network, channel, (loadMoreResponse) {
      listener(MessagesForChannel(channel, loadMoreResponse.messages));
    }));

    return disposable;
  }

  Future<SpecialMessage> _toWhoIsSpecialMessage(
      MsgLoungeResponseBody data) async {
    var whoIsSpecialBody = toWhoIsSpecialMessageBody(data.msg.whois);

    var linksInMessage = await findUrls([
      whoIsSpecialBody.actualHostname,
      whoIsSpecialBody.realName,
      whoIsSpecialBody.account,
      whoIsSpecialBody.server,
      whoIsSpecialBody.serverInfo
    ]);
    return SpecialMessage.name(
        channelRemoteId: data.chan,
        data: whoIsSpecialBody,
        specialType: SpecialMessageType.whoIs,
        date: DateTime.now(),
        linksInMessage: linksInMessage);
  }

  @override
  Disposable listenForChannelJoin(Network network, ChannelListener listener) {
    _logger.d(() => "listenForChannelJoin $network");

    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable(JoinLoungeResponseBody.eventName, (raw) {
      var parsed = JoinLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "listenForChannelJoin "
          "parsed $parsed network.remoteId = $network.remoteId");
      if (parsed.network == network.remoteId) {
        ChatJoinChannelInputLoungeJsonRequest request =
            _findJoinChannelOriginalRequest(_pendingRequests, parsed);

        var preferences;

        if (request != null) {
          preferences = ChannelPreferences.name(
              localId: request.preferences.localId,
              name: parsed.chan.name,
              password: request.preferences.password);
          _pendingRequests.remove(request);
        } else {
          preferences =
              ChannelPreferences.name(name: parsed.chan.name, password: "");
        }

        var loungeChannel = parsed.chan;

        toChannelWithState(loungeChannel).then((channelWithState) {
          channelWithState.channel.channelPreferences = preferences;

          listener(channelWithState);
        });
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForChannelLeave(
      Network network, Channel channel, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (PartLoungeResponseBody.eventName), (raw) {
      var parsed = PartLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.chan == channel.remoteId) {
        listener();
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForChannelState(
      Network network,
      Channel channel,
      ChannelState Function() currentStateExtractor,
      ChannelStateListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable(MsgLoungeResponseBody.eventName, (raw) {
      var data = MsgLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        if (data.unread != null) {
          var channelState = currentStateExtractor();
          channelState.unreadCount = data.unread;
          listener(channelState);
        }
      }
    }));
    disposable.add(
        createEventListenerDisposable(MoreLoungeResponseBody.eventName, (raw) {
      var parsed = MoreLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == parsed.chan) {
        var channelState = currentStateExtractor();
        channelState.moreHistoryAvailable = parsed.moreHistoryAvailable;
        listener(channelState);
      }
    }));

    disposable.add(
        createEventListenerDisposable(TopicLoungeResponseBody.eventName, (raw) {
      var data = TopicLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var channelState = currentStateExtractor();
        channelState.topic = data.topic;
        listener(channelState);
      }
    }));

    disposable.add(createEventListenerDisposable(
        ChannelStateLoungeResponseBody.eventName, (raw) {
      var data =
          ChannelStateLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var channelState = currentStateExtractor();
        if (data.state == ChannelStateLoungeConstants.connected) {
          channelState.connected = true;
        } else {
          channelState.connected = false;
        }

        listener(channelState);
      }
    }));

    return disposable;
  }

  Disposable listenForChannelUsers(
      Network network, Channel channel, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (UsersLoungeResponseBody.eventName), (raw) {
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

    disposable.add(createEventListenerDisposable(
        NetworkLoungeResponseBody.eventName, (raw) {
      var parsed = NetworkLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "listenForNetworkJoin parsed = $parsed");

      for (var loungeNetwork in parsed.networks) {
        // Why lounge sent array of networks?
        // It is possible to join only one network Lounge API per request
        // Lounge should send only one network in this response
        // todo: open ticket for lounge
        ChatNetworkNewLoungeJsonRequest request =
            _findOriginalJoinNetworkRequest(_pendingRequests, loungeNetwork);

        _pendingRequests.remove(request);

        var connectionPreferences =
            request.networkPreferences.networkConnectionPreferences;

        // when requested nick is not available and server give new nick
        var nick = loungeNetwork.nick;
        connectionPreferences.userPreferences.nickname = nick;

        toNetworkWithState(loungeNetwork).then((networkWithState) {
          networkWithState.network.localId = request.networkPreferences.localId;

          networkWithState.network.channels.forEach((channel) {
            var channelPreferences = request.networkPreferences.channels
                .firstWhere((channelPreferences) {
              return channel.name == channelPreferences.name;
            }, orElse: () => null);

            if (channelPreferences != null) {
              channel.localId = channelPreferences.localId;
            }
          });

          networkWithState.network.connectionPreferences =
              connectionPreferences;

          listener(networkWithState);
        });
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkLeave(Network network, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (QuitLoungeResponseBody.eventName), (raw) {
      var parsed = QuitLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        listener();
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForMessagePreviews(Network network, Channel channel,
      ChannelMessagePreviewListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (MsgPreviewLoungeResponseBody.eventName), (raw) {
      var parsed =
          MsgPreviewLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.chan == channel.remoteId) {
        listener(MessagePreviewForRemoteMessageId(
            parsed.id, toMessagePreview(parsed.preview)));
      }
    }));

    return disposable;
  }

  @override
  Disposable listenForNetworkEdit(
      Network network, NetworkConnectionListener listener) {
    return StreamSubscriptionDisposable(
        _editNetworkRequests.listen((NetworkPreferences networkPreferences) {
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

    disposable.add(StreamSubscriptionDisposable(
        _editNetworkRequests.listen((NetworkPreferences networkPreferences) {
      if (network.connectionPreferences.localId == networkPreferences.localId) {
        var currentState = currentStateExtractor();
        currentState.name = networkPreferences
            .networkConnectionPreferences.serverPreferences.name;
        listener(currentState);
      }
    })));

    disposable.add(createEventListenerDisposable(
        (NickLoungeResponseBody.eventName), (raw) {
      var parsed = NickLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        var currentState = currentStateExtractor();
        currentState.nick = parsed.nick;
        listener(currentState);
      }
    }));

    disposable.add(createEventListenerDisposable(
        (NetworkOptionsLoungeResponseBody.eventName), (raw) {
      var parsed =
          NetworkOptionsLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        // nothing to change right now
        var currentState = currentStateExtractor();
        listener(currentState);
      }
    }));

    disposable.add(createEventListenerDisposable(
        (NetworkStatusLoungeResponseBody.eventName), (raw) {
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
  Future<RequestResult<bool>> sendChannelOpenedEventToServer(
      Network network, Channel channel) async {
    _sendRequest(
        ChannelOpenedLoungeRawRequest.name(channelRemoteId: channel.remoteId),
        isNeedAddRequestToPending: false);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> sendDevicePushFCMTokenToServer(String newToken,
      {bool waitForResult = false}) async {
    _logger.d(() => "sendDevicePushFCMTokenToServer $newToken");

    _sendRequest(PushFCMTokenLoungeJsonRequest.name(token: newToken),
        isNeedAddRequestToPending: false);

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
      Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, ChannelsListIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<RegularMessage>> printChannelBannedUsers(
      Network network, Channel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(network, channel, BanListIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(
        network, network.lobbyChannel, IgnoreListIRCCommand().asRawString);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<RegularMessage>> sendChannelRawMessage(
      Network network, Channel channel, String rawMessage,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }
    _sendInputRequest(network, channel, rawMessage);
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Disposable listenForChannelNames(
      Network network, Channel channel, Function(List<ChannelUser>) listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(createEventListenerDisposable(
        (NamesLoungeResponseBody.eventName), (raw) {
      var parsed = NamesLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "listenForChannelUsers $parsed for $channel");

      if (parsed.id == channel.remoteId) {
        listener(parsed.users
            .map((loungeUser) => toChannelUser(loungeUser))
            .toList());
      }
    }));

    return disposable;
  }

  _sendRequest(LoungeRequest request,
      {@required bool isNeedAddRequestToPending}) async {
    if (isNeedAddRequestToPending) {
      _pendingRequests.add(request);
    }

    _logger.d(() => "_sendCommand $request");
    var socketIOCommand = toSocketIOCommand(request);
    _logger.d(() => "socketIOCommand $socketIOCommand");
    return await _socketIOService.emit(socketIOCommand);
  }

  disconnect() async {
    var result;

    result = await _socketIOService.disconnect();
    return result;
  }

  @override
  void dispose() {
    super.dispose();

    _socketIOService.dispose();
  }

  void _sendInputRequest(Network network, Channel channel, String message) {
    if (_isCollapseClientSideCommand(message)) {
      _channelTogglePreviewSubject
          .add(ToggleChannelPreviewData(network, channel, false));
    } else if (_isExpandClientSideCommand(message)) {
      _channelTogglePreviewSubject
          .add(ToggleChannelPreviewData(network, channel, true));
    } else {
      _sendRequest(
          InputLoungeJsonRequest.name(target: channel.remoteId, text: message),
          isNeedAddRequestToPending: false);
    }
  }

  bool _isExpandClientSideCommand(String message) =>
      message.startsWith(ClientSideLoungeIRCCommandConstants.expand);

  bool _isCollapseClientSideCommand(String message) =>
      message.startsWith(ClientSideLoungeIRCCommandConstants.collapse);

  @override
  Future<RequestResult<String>> uploadFile(File file) async {
    String uploadFileToken;

    var disposable = _createEventListenerDisposable(
        _socketIOService, UploadAuthLoungeResponseBody.eventName, (raw) {
      var parsed = UploadAuthLoungeResponseBody.fromRaw(raw);

      uploadFileToken = parsed.uploadAuthToken;
    });
    _socketIOService.emit(toSocketIOCommand(UploadAuthLoungeEmptyRequest()));

    await _doWaitForResult(() => uploadFileToken);

    disposable.dispose();

    String loungeUrl = _loungePreferences.connectionPreferences.host;
    var uploadedFileRemoteURL = await uploadFileToLounge(
        loungeUrl, file, uploadFileToken, chatConfig.fileUploadMaxSizeInBytes);

    return RequestResult.name(
        isSentSuccessfully: true, result: uploadedFileRemoteURL);
  }

  Disposable listenForLoadMore(Network network, Channel channel,
      Function(MessageListLoadMore) callback) {
    var disposable = CompositeDisposable([]);

    disposable.add(createEventListenerDisposable(
        (MoreLoungeResponseBody.eventName), (raw) {
      var parsed = MoreLoungeResponseBody.fromJson(_preProcessRawData(raw));

      _logger.d(() => "loadMoreHistory $parsed for $channel");

      if (parsed.chan == channel.remoteId) {
        toChatLoadMore(channel, parsed).then((chatLoadMore) {
          callback(chatLoadMore);
        });
      }
    }));

    return disposable;
  }

  Disposable listenForSignOut(VoidCallback callback) {
    var disposable = CompositeDisposable([]);

    disposable.add(StreamSubscriptionDisposable(
        _signOutSubject.stream.listen((manualSignOut) {
      if (manualSignOut == true) {
        callback();
      }
    })));
    disposable.add(createEventListenerDisposable(
        (SignOutLoungeResponseBody.eventName), (raw) {
      _logger.d(() => "listenForSignOut $raw");
      callback();
    }));

    return disposable;
  }

  @override
  Future<RequestResult<MessageListLoadMore>> loadMoreHistory(
      Network network, Channel channel, int lastMessageId) async {
    var disposable = CompositeDisposable([]);

    MessageListLoadMore chatLoadMore;

    disposable.add(listenForLoadMore(network, channel, (loadMoreResponse) {
      chatLoadMore = loadMoreResponse;
    }));

    _sendRequest(
        MoreLoungeJsonRequest.name(
            target: channel.remoteId, lastId: lastMessageId),
        isNeedAddRequestToPending: false);

    await _doWaitForResult(() => chatLoadMore);

    disposable.dispose();

    return RequestResult.name(isSentSuccessfully: true, result: chatLoadMore);
  }

  // ignore: close_sinks
  BehaviorSubject<ToggleMessagePreviewData> _messageTogglePreviewSubject =
      BehaviorSubject();

  Disposable listenForMessagePreviewToggle(Network network, Channel channel,
      Function(ToggleMessagePreviewData) callback) {
    return StreamSubscriptionDisposable(_messageTogglePreviewSubject.stream
        .listen((ToggleMessagePreviewData toggle) {
      if (toggle.channel == channel) {
        callback(toggle);
      }
    }));
  }

  // ignore: close_sinks
  BehaviorSubject<ToggleChannelPreviewData> _channelTogglePreviewSubject =
      BehaviorSubject();

  Disposable listenForChannelPreviewToggle(Network network, Channel channel,
      Function(ToggleChannelPreviewData) callback) {
    return StreamSubscriptionDisposable(_channelTogglePreviewSubject.stream
        .listen((ToggleChannelPreviewData toggle) {
      if (toggle.channel == channel) {
        callback(toggle);
      }
    }));
  }

  @override
  Future<RequestResult<ToggleMessagePreviewData>> togglePreview(Network network,
      Channel channel, RegularMessage message, MessagePreview preview,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetLoungeException();
    }

    var shownInverted = !preview.shown;
    preview.shown = shownInverted;
    _sendRequest(
        MsgPreviewToggleLoungeJsonRequest.name(
            target: channel.remoteId,
            msgId: message.messageRemoteId,
            link: preview.link,
            shown: shownInverted),
        isNeedAddRequestToPending: false);

    var chatTogglePreview = ToggleMessagePreviewData.name(
        network, channel, message, preview, shownInverted);

    _messageTogglePreviewSubject.add(chatTogglePreview);
    return RequestResult(true, chatTogglePreview);
  }

  void signOut() {
    _signOutSubject.add(true);

    _sendRequest(SignOutLoungeEmptyRequest(), isNeedAddRequestToPending: false);
  }
}

Disposable _listenForConfiguration(SocketIOService _socketIOService,
    Function(ConfigurationLoungeResponseBody) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (ConfigurationLoungeResponseBody.eventName), (raw) {
    var parsed =
        ConfigurationLoungeResponseBody.fromJson(_preProcessRawData(raw));

    listener(parsed);
  }));

  return disposable;
}

Disposable _listenForAuth(
    SocketIOService _socketIOService, Function(bool success) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (AuthLoungeResponseBody.eventName), (raw) {
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
      _socketIOService, (CommandsLoungeResponseBody.eventName), (raw) {
    var parsed = CommandsLoungeResponseBody.fromRaw(raw);

    listener(parsed.commands);
  }));

  return disposable;
}

Disposable _listenForAuthorized(
    SocketIOService _socketIOService, VoidCallback listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (AuthorizedLoungeResponseBody.eventName), (raw) {
    _logger.d(() => "_listenForAuthorized = $raw}");
    listener();
  }));

  return disposable;
}

Disposable _listenForInit(SocketIOService _socketIOService,
    Function(ChatInitInformation init) listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (InitLoungeResponseBody.eventName), (raw) {
    _logger.d(() => "_listenForInit = $raw}");
    var parsed = InitLoungeResponseBody.fromJson(_preProcessRawData(raw));

    toChatInitInformation(parsed).then((chatInit) {
      listener(chatInit);
    });
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
      result.isPrivateModeResponseReceived =
          authResponse != null || result.isAuthRequestSent;

      if (result.isPrivateModeResponseReceived &&
          !result.isAuthRequestSent &&
          authPreferencesExist) {
        var authRequest = AuthLoungeJsonRequestBody.name(
            user: authPreferences.username, password: authPreferences.password);

        authResponse = null;
        socketIOService.emit(toSocketIOCommand(authRequest));
        result.isAuthRequestSent = true;
        _logger.d(() => "_connect send auth = $authRequest");
      }

      result.isFailAuthResponseReceived =
          authResponse != null ? authResponse == false : false;

      isNeedWait = !result.isTimeout;
      isNeedWait &= !result.isFailAuthResponseReceived;
      isNeedWait &= result.error == null;
      isNeedWait &= !authorizedResponseReceived;
      // private mode but login/password not specified
      isNeedWait &= !result.isPrivateModeResponseReceived ||
          (result.isPrivateModeResponseReceived && result.isAuthRequestSent);
    } while (isNeedWait);
  }

  _logger.d(() => "_connect end wait "
      "authorizedResponseReceived = $authorizedResponseReceived "
      ".isTimeout = ${result.isTimeout} "
      ".isPrivateModeResponseReceived = ${result.isPrivateModeResponseReceived} "
      ".isAuthRequestSent = ${result.isAuthRequestSent} "
      ".error = ${result.error}");

  disposable.dispose();

  var configReceived = loungeConfig != null;
  var commandsReceived = loungeCommands != null;
  var chatInitReceived = result.chatInit != null;

  _logger.d(() => "_connect result = $result configReceived = $configReceived"
      " commandsReceived = $commandsReceived "
      "authorizedReceived = $authorizedReceived");

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

ChatJoinChannelInputLoungeJsonRequest _findJoinChannelOriginalRequest(
    List<LoungeRequest> pendingRequests, JoinLoungeResponseBody parsed) {
  return pendingRequests.firstWhere((request) {
    if (request is ChatJoinChannelInputLoungeJsonRequest) {
      ChatJoinChannelInputLoungeJsonRequest joinRequest = request;
      if (joinRequest != null) {
        if (joinRequest.preferences.name == parsed.chan.name) {
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
}

ChatNetworkNewLoungeJsonRequest _findOriginalJoinNetworkRequest(
    List<LoungeRequest> pendingRequests,
    NetworkLoungeResponseBodyPart loungeNetwork) {
  return pendingRequests.firstWhere((request) {
    var loungeJsonRequest = request as ChatNetworkNewLoungeJsonRequest;
    if (loungeJsonRequest != null) {
      if (loungeNetwork.name == loungeJsonRequest.name) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }, orElse: () => null);
}
