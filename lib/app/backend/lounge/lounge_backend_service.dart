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
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/socketio/socketio_model.dart';
import 'package:flutter_appirc/socketio/socketio_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "LoungeService", enabled: true);

var _connectTimeout = Duration(seconds: 5);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);

const _timeoutForRequestsWithResponse = Duration(seconds: 10);
const _timeBetweenCheckResultForRequestsWithResponse =
    Duration(milliseconds: 100);

class LoungeBackendService extends Providable
    implements ChatInputOutputBackendService {
  final LoungeConnectionPreferences _loungePreferences;
  final SocketIOManager socketIOManager;
  SocketIOService _socketIOService;

  @override
  ChatConfig chatConfig;

  @override
  // TODO: implement isReadyToConnect
  bool get isReadyToConnect =>
      _socketIOService != null &&
      connectionState == ChatConnectionState.DISCONNECTED &&
      _loungePreferences != null &&
      _loungePreferences != LoungeConnectionPreferences.empty;

  final List<LoungeRequest> _pendingRequests = [];

  LoungeBackendService(this.socketIOManager, this._loungePreferences) {
    addDisposable(subject: _connectionStateController);
  }

  Future init() async {
    _logger.d(() => "init started");

    var host = _loungePreferences.host;
    if (_loungePreferences == LoungeConnectionPreferences.empty) {
      // workaround because socket io requires valid url
      // todo rework
      host = "https://demo.thelounge.chat/";
    }
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

  // lounge dont support socket io default connect/connecting commands
  // TODO: rework when launch will support it
//  @override
//  Stream<ChatConnectionState> get connectionStateStream =>
//      _socketIOService.connectionStateStream.map(mapState);
//
//  ChatConnectionState get connectionState =>
//      mapState(_socketIOService.connectionState);

  Future<RequestResult<bool>> tryConnectWithDifferentPreferences(
      LoungeConnectionPreferences preferences) async {
    SocketIOService socketIOService;
    var connected = false;
    try {
      socketIOService = SocketIOService(socketIOManager, preferences.host);
      await socketIOService.init();
      var chatConfig = await _connect(preferences, socketIOService);
      connected = chatConfig != null;
    } finally {
      if (socketIOService != null && connected) {
        socketIOService.disconnect();
      }
    }

    return RequestResult(true, connected);
  }

  @override
  Future<RequestResult<bool>> connectChat() async {
    assert(_loungePreferences != LoungeConnectionPreferences.empty);

    _connectionStateController.add(ChatConnectionState.CONNECTING);

    var chatConfig = await _connect(_loungePreferences, _socketIOService);

    bool result;
    if (chatConfig != null) {
      this.chatConfig = chatConfig;
      result = true;
    } else {
      result = false;
    }

    _logger.d(() => "connectChat = $result chatConfig = $chatConfig");

    if (result) {
      _connectionStateController.add(ChatConnectionState.CONNECTED);
    } else {
      _connectionStateController.add(ChatConnectionState.DISCONNECTED);
    }

    return RequestResult(true, result);
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
      Network network, IRCNetworkPreferences preferences,
      {bool waitForResult = false}) {
//    if (waitForResult) {
    throw NotImplementedYetException();
//    }
//    // TODO: implement editNetworkSettings
//    return null;
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
  Future<RequestResult<List<ChannelUserInfo>>> getNetworkChannelUsers(
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
  Future<RequestResult<ChannelUserInfo>> printUserInfo(
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
      IRCNetworkPreferences networkPreferences,
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
        NetworkNewLoungeRequestBody(
          username: userPreferences.username,
          nick: userPreferences.nickname,
          join: join,
          realname: userPreferences.realName,
          password: userPreferences.password,
          host: serverPreferences.serverHost,
          port: serverPreferences.serverPort,
          rejectUnauthorized: serverPreferences.useOnlyTrustedCertificates
              ? LoungeConstants.on
              : LoungeConstants.off,
          tls: serverPreferences.useTls
              ? LoungeConstants.on
              : LoungeConstants.off,
          name: serverPreferences.name,
        ));

    var result;
    Disposable networkListener;
    networkListener = listenForNetworkEnter((networkWithState) async {
      var networkFromResult = networkWithState.network;

      if (networkFromResult.name == serverPreferences.name) {
        var channelsWithPassword = networkPreferences.channelsWithPassword;
        for (var channelPreferences in channelsWithPassword) {
          var joinChannelResult = await joinNetworkChannel(
              networkWithState.network, channelPreferences,
              waitForResult: true);
          var channel = joinChannelResult.result.channel;
          assert(channel != null);
          networkFromResult.channels.add(channel);
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
        result = RequestResult(true, null);
      }
    });

    while (result != null) {
      await Future.delayed(_timeBetweenCheckResultForRequestsWithResponse);
      T extracted = resultExtractor();
      if (extracted != null) {
        result = RequestResult(true, extracted);
      }
    }

    return result;
  }

  @override
  Future<RequestResult<NetworkChannelWithState>> joinNetworkChannel(
      Network network, IRCNetworkChannelPreferences preferences,
      {bool waitForResult = false}) async {
    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: InputLoungeRequestBody(
            target: network.lobbyChannel.remoteId,
            content: "/join ${preferences.name} ${preferences.password}"));

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
        listener(message);
      }
    }));

    disposable.add(createEventListenerDisposable(
        LoungeResponseEventNames.msgSpecial, (raw) {
      var data =
          MessageSpecialLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var specialMessages = toSpecialMessages(channel, data.data);

        specialMessages.forEach((specialMessage) {
          listener(specialMessage);
        });
      }
    }));

//    _messagesSpecialController.sink.add(data);
//    _logger.i(() => "_onNickResponse $raw");
//    var data = NickLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _nickController.sink.add(data);

    return disposable;
  }

  @override
  Disposable listenForNetworkChannelJoin(
      Network network, NetworkChannelListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable(LoungeResponseEventNames.join, (raw) {
      var parsed = JoinLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        LoungeJsonRequest<JoinChannelInputLoungeRequestBody> request =
            _pendingRequests.firstWhere((request) {
          var joinRequest =
              request as LoungeJsonRequest<JoinChannelInputLoungeRequestBody>;
          if (joinRequest != null) {
            if (joinRequest.body.channelName == parsed.chan.name) {
              return true;
            }
          } else {
            return false;
          }

          return false;
        }, orElse: () => null);

        var preferences;

        if (request != null) {
          preferences = IRCNetworkChannelPreferences.name(
              localId: request.body.localId,
              name: parsed.chan.name,
              password: request.body.channelPassword);
        } else {
          preferences = IRCNetworkChannelPreferences.name(
              name: parsed.chan.name, password: "");
        }

        var loungeChannel = parsed.chan;

        var networkChannel = NetworkChannel(preferences,
            detectNetworkChannelType(parsed.chan.type), parsed.chan.id);
        var channelState = toNetworkChannelState(loungeChannel);
        listener(NetworkChannelWithState(networkChannel, channelState));
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

//          cg  listener(message);
      }
    }));

    disposable.add(
        createEventListenerDisposable(LoungeResponseEventNames.topic, (raw) {
      var data = TopicLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var channelState = currentStateExtractor();
        channelState.topic = data.topic;
        listener(channelState);
//        var message = toIRCMessage(data.msg);
//        listener(message);
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

    // TODO: implement listenForNetworkChannelState
    //    _logger.i(() => "_onTopicResponse $raw");
//    var data = TopicLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _topicController.sink.add(data);
//    var parsed =
//        ChannelStateLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _channelStateController.sink.add(parsed);
    return disposable;
  }

  @override
  Disposable listenForNetworkEnter(NetworkListener listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable(LoungeResponseEventNames.network, (raw) {
      var parsed = NetworksLoungeResponseBody.fromJson(_preProcessRawData(raw));

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

        var channelsWithState = <NetworkChannelWithState>[];

        for (var loungeChannel in loungeNetwork.channels) {
          var networkChannelPreferences = request.networkPreferences.channels
              .firstWhere((channelPreferences) {
            return loungeChannel.name == channelPreferences.name;
          }, orElse: ()=>null);
          int localId;
          if (networkChannelPreferences != null) {
            localId = networkChannelPreferences.localId;
          }
          var channel = NetworkChannel(
              IRCNetworkChannelPreferences.name(
                  localId: localId,
                  name: loungeChannel.name,
                  // Network start channels always without password
                  password: ""),
              detectNetworkChannelType(loungeChannel.type),
              loungeChannel.id);
          var channelState = toNetworkChannelState((loungeChannel));
          channelsWithState.add(NetworkChannelWithState(channel, channelState));
        }

        var channels = channelsWithState
            .map((channelWithState) => channelWithState.channel)
            .toList();

        var network =
            Network(connectionPreferences, loungeNetwork.uuid, channels);

        network.localId = request.networkPreferences.localId;

        var loungeNetworkStatus = loungeNetwork.status;

        var networkState = toNetworkState(loungeNetworkStatus);

        listener(NetworkWithState(network, networkState, channelsWithState));
      }
    }));

    return disposable;

    // TODO: implement listenForNetworkChannelState
    //    var parsed = NetworksLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _logger.i(() => "_onNetworkResponse parsed $parsed");
//    _networksController.sink.add(parsed);
  }

  @override
  Disposable listenForNetworkExit(Network network, VoidCallback listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.part), (raw) {
      var parsed = QuitLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.network == network.remoteId) {
        listener();
      }
    }));

    return disposable;
  }

  Disposable listenForNetworkState(
      Network network,
      NetworkState Function() currentStateExtractor,
      NetworkStateListener listener) {
    var disposable = CompositeDisposable([]);

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
        var newState = toNetworkState(parsed);
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
  Disposable listenForNetworkChannelUsers(Network network,
      NetworkChannel channel, Function(List<ChannelUserInfo>) listener) {
    var disposable = CompositeDisposable([]);
    disposable.add(
        createEventListenerDisposable((LoungeResponseEventNames.names), (raw) {
      var parsed = NamesLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (parsed.id == channel.remoteId) {
        listener(parsed.users
            .map((loungeUser) => ChannelUserInfo.name(
                nick: loungeUser.nick, mode: loungeUser.mode))
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
    listener();
  }));

  return disposable;
}

Disposable _listenForAuth(
    SocketIOService _socketIOService, VoidCallback listener) {
  var disposable = CompositeDisposable([]);
  disposable.add(_createEventListenerDisposable(
      _socketIOService, (LoungeResponseEventNames.auth), (raw) {
    listener();
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

Future<ChatConfig> _connect(LoungeConnectionPreferences preferences,
    SocketIOService socketIOService) async {
  _logger.d(() => "start connect to $preferences");
  var disposable = CompositeDisposable([]);

  ConfigurationLoungeResponseBody loungeConfig;
  List<String> loungeCommands;
  bool authorizedReceived = false;
  bool authReceived = false;
  bool timeout = false;

  disposable.add(_listenForConfiguration(
      socketIOService, (result) => loungeConfig = result));
  disposable.add(
      _listenForAuthorized(socketIOService, () => authorizedReceived = true));
  disposable.add(_listenForAuth(socketIOService, () => authReceived = true));
  disposable.add(
      _listenForCommands(socketIOService, (result) => loungeCommands = result));

  Future.delayed(_connectTimeout, () => timeout = true);

  await socketIOService.connect();
  // lounge don't support connect/connecting callbacks
  // TODO: should be changed if lounge will start support it
  var socketConnected = true;

  _logger.d(() => "_connect socketConnected= $socketConnected");

  if (socketConnected) {
    while ((loungeCommands == null && loungeConfig == null ||
            authorizedReceived == false) &&
        !timeout &&
        authReceived == false) {
      await Future.delayed(_timeBetweenCheckingConnectionResponse);
    }
  }

  disposable.dispose();

  var commandsReceived = loungeCommands != null;
  var configReceived = loungeConfig != null;

  _logger.d(() => "_connect commandsReceived = $commandsReceived "
      "configReceived = $configReceived authorizedReceived = $authorizedReceived, authReceived = $authReceived");

  if (socketConnected) {
    if (authReceived) {
      throw PrivateLoungeNotSupportedException(preferences);
    } else {
      if (commandsReceived && configReceived && authorizedReceived) {
        if (loungeConfig.public) {
          ChatConfig chatConfig = toChatConfig(loungeConfig, loungeCommands);
          return chatConfig;
        } else {
          throw PrivateLoungeNotSupportedException(preferences);
        }
      } else {
        if (!commandsReceived && !configReceived && !authorizedReceived) {
          return null;
        } else {
          try {
            socketIOService.disconnect();
          } on Exception catch (e) {
            _logger.e(() => "Error during disconnecting on fail connect $e");
          }

          // something received something not
          throw InvalidConnectionResponseException(preferences,
              authorizedReceived, configReceived, commandsReceived);
        }
      }
    }
  } else {
    return null;
  }
}
