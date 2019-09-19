import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:adhara_socket_io/manager.dart';
import 'package:adhara_socket_io/socket.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_adapter.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/socketio/socketio_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "LoungeService", enabled: true);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);
const _timeoutForRequestsWithResponse = Duration(seconds: 10);
const _timeBetweenCheckResultForRequestsWithResponse =
    Duration(milliseconds: 100);

class LoungeBackendService extends Providable
    implements ChatInputOutputBackendService {
  final LoungeConnectionPreferences _loungePreferences;
  final SocketIOManager socketIOManager;
  SocketIOService _socketIOService;

  final List<LoungeRequest> _oldRequests = [];

  LoungeBackendService(this.socketIOManager, this._loungePreferences) {
    addDisposable(subject: _connectionController);

    var host = _loungePreferences.host;
    if (_loungePreferences == LoungeConnectionPreferences.empty) {
      // workaround because socket io requires valid url
      // todo rework
      host = "https://demo.thelounge.chat/";
    }
    _socketIOService = SocketIOService(socketIOManager, host);
  }

  Future init() async {
    await _socketIOService.init();
    _subscribeConnectionState();
  }

  Disposable listenConnectionState(
      void Function(ChatConnectionState) listener) {
    SocketEventListener connectListener =
        (_) => listener(ChatConnectionState.CONNECTED);
    SocketEventListener disconnectListener =
        (_) => listener(ChatConnectionState.DISCONNECTED);
    SocketEventListener connectErrorListener =
        (_) => listener(ChatConnectionState.DISCONNECTED);
    SocketEventListener connectTimeoutListener =
        (_) => listener(ChatConnectionState.DISCONNECTED);
    SocketEventListener connectingListener =
        (_) => listener(ChatConnectionState.CONNECTING);
    SocketEventListener reconnectListener =
        (_) => listener(ChatConnectionState.CONNECTED);
    SocketEventListener reconnectFailedListener =
        (_) => listener(ChatConnectionState.DISCONNECTED);
    SocketEventListener reconnectErrorListener =
        (_) => listener(ChatConnectionState.DISCONNECTED);
    SocketEventListener reconnectingListener =
        (_) => listener(ChatConnectionState.CONNECTING);
    _socketIOService.onConnect(connectListener);
    _socketIOService.onDisconnect(disconnectListener);
    _socketIOService.onConnectError(connectErrorListener);
    _socketIOService.onConnectTimeout(connectTimeoutListener);
    _socketIOService.onConnecting(connectingListener);
    _socketIOService.onReconnect(reconnectListener);
    _socketIOService.onReconnectFailed(reconnectFailedListener);
    _socketIOService.onReconnectError(reconnectErrorListener);
    _socketIOService.onReconnecting(reconnectingListener);

    return CustomDisposable(() {
      _socketIOService.offConnect(connectListener);
      _socketIOService.offDisconnect(disconnectListener);
      _socketIOService.offConnectError(connectErrorListener);
      _socketIOService.offConnectTimeout(connectTimeoutListener);
      _socketIOService.offConnecting(connectingListener);
      _socketIOService.offReconnect(reconnectListener);
      _socketIOService.offReconnectFailed(reconnectFailedListener);
      _socketIOService.offReconnectError(reconnectErrorListener);
      _socketIOService.offReconnecting(reconnectingListener);
    });
  }

  Stream<ChatConnectionState> get connectedStream =>
      _connectionController.stream;

  bool get isConnected =>
      _connectionController.value == ChatConnectionState.CONNECTED;

  var _connectionController = BehaviorSubject<ChatConnectionState>(
      seedValue: ChatConnectionState.DISCONNECTED);

  @override
  Stream<ChatConnectionState> get connectionStateStream =>
      _connectionController.stream;

  ChatConnectionState get connectionState => _connectionController.value;

  void _subscribeConnectionState() {
    addDisposable(disposable: listenConnectionState((_loungeConnectionState) {
      _connectionController.add(_loungeConnectionState);
    }));
  }

  Future<RequestResult<bool>> tryConnectWithDifferentPreferences(
      LoungeConnectionPreferences preferences) async {
    // TODO: implement tryConnectWithDifferentPreferences
    return RequestResult.name(isSentSuccessfully: true, result: true);
  }

  @override
  Future<RequestResult<bool>> connectChat({bool waitForResult = false}) async {
//  void _onConfigurationResponse(raw) {
//    var parsed =
//        ConfigurationLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _configurationController.sink.add(parsed);
//  }
//
//  void _onAuthorizedResponse(raw) {
//    _authorizedController.sink.add(null);
//  }
//
//      _logger.i(() => "_onCommandResponse $raw");
//    var parsed = raw;
//    _commandsController.sink.add(parsed);

    if (_loungePreferences == LoungeConnectionPreferences.empty) {
      return RequestResult.name(isSentSuccessfully: false, result: false);
    }

    _logger.i(() => "start connecting to $_loungePreferences");

    var connected = false;
    var responseReceived = false;

    Exception connectionException;

    var connectListener = (_) {
      _logger.i(() => "connecting onConnect");
      connected = true;
      responseReceived = true;
    };
    _socketIOService.onConnect(connectListener);

    var connectErrorListener = (value) {
      _logger.e(() => "connecting onConnectError $value");
      connectionException = ConnectionErrorLoungeException(value);
      responseReceived = true;
    };
    _socketIOService.onConnectError(connectErrorListener);
    var connectTimeoutListener = (value) {
      _logger.e(() => "connecting onConnectTimeout $value");
      connectionException = ConnectionTimeoutLoungeException();
      responseReceived = true;
    };
    _socketIOService.onConnectTimeout(connectTimeoutListener);

    _logger.i(() => "start socket connect");
    await _socketIOService.connect();

    if (waitForResult) {
      while (!responseReceived) {
        await Future.delayed(_timeBetweenCheckingConnectionResponse);
      }

      _logger.i(() => "finish connecting connected = $connected");

      _socketIOService.offConnect(connectListener);
      _socketIOService.offConnectTimeout(connectTimeoutListener);
      _socketIOService.offConnectError(connectErrorListener);

      if (connectionException != null) {
        connected = false;
      }

      return RequestResult.name(isSentSuccessfully: true, result: connected);
    } else {
      return RequestResult.name(isSentSuccessfully: true, result: null);
    }
  }

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
    _sendInputRequest(network, network.lobbyChannel, "/disconnect");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<bool>> disableNetwork(Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/connect");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<List<ChannelUserInfo>>> getNetworkChannelUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }

    _sendRequest(LoungeJsonRequest(
        name: LoungeRequestEventNames.names,
        body: NamesLoungeRequestBody.name(target: channel.remoteId)));

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<ChannelUserInfo>> getUserInfo(
      Network network, NetworkChannel channel, String userNick,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, "/whois $userNick");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<Network>> joinNetwork(IRCNetworkPreferences preferences,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }

    var userPreferences =
        preferences.networkConnectionPreferences.userPreferences;
    var networkPreferences =
        preferences.networkConnectionPreferences.serverPreferences;

    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.networkNew,
        body: NetworkNewLoungeRequestBody(
          username: userPreferences.username,
          nick: userPreferences.nickname,
          join: preferences.channelsString,
          realname: userPreferences.realName,
          password: userPreferences.password,
          host: networkPreferences.serverHost,
          port: networkPreferences.serverPort,
          rejectUnauthorized: networkPreferences.useOnlyTrustedCertificates
              ? LoungeConstants.on
              : LoungeConstants.off,
          tls: networkPreferences.useTls
              ? LoungeConstants.on
              : LoungeConstants.off,
          name: networkPreferences.name,
        ));

    _sendRequest(request);

    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkChannel>> joinNetworkChannel(
      Network network, IRCNetworkChannelPreferences preferences,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel,
        "/join ${preferences.name} ${preferences.password}");
    return RequestResult.name(isSentSuccessfully: true, result: null);
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

  Disposable createEventListenerDisposable(
      String eventName, Function(dynamic raw) listener) {
    _socketIOService.on(eventName, listener);
    return CustomDisposable(() => _socketIOService.off(eventName, listener));
  }

  @override
  Disposable listenForMessages(Network network, NetworkChannel channel,
      NetworkChannelMessageListener listener) {
    var disposable = CompositeDisposable([]);
    disposable
        .add(createEventListenerDisposable(LoungeResponseEventNames.msg, (raw) {
      var data = MessageLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var message = toIRCMessage(data.msg);
        listener(message);
      }
    }));

    disposable.add(createEventListenerDisposable(
        LoungeResponseEventNames.msgSpecial, (raw) {
      var data =
          MessageSpecialLoungeResponseBody.fromJson(_preProcessRawData(raw));

      if (channel.remoteId == data.chan) {
        var message = IRCChatSpecialMessage(data.data);
        listener(message);
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
        var request = _oldRequests.firstWhere((request) {
          var loungeJsonRequest =
              request as LoungeJsonRequest<InputLoungeRequestBody>;
          if (loungeJsonRequest != null) {
            var content = loungeJsonRequest.body.content;
            if (content.contains("/join")) {
              var command = content.split(" ");

              var channelName = command[1];

              if (channelName == parsed.chan.name) {
                return true;
              }

              return true;
            } else {
              return false;
            }
          }
          return false;
        }, orElse: () => null) as LoungeJsonRequest<InputLoungeRequestBody>;

        var preferences;

//            if(request != null) {
//
//              var command = content.split(" ");
//
//              var channelName = command[1];
//
//              var password;
//              if(command.length > 2) {
//                password = command[2];
//              }
//            } else {
        preferences = IRCNetworkChannelPreferences.name(
            name: parsed.chan.name, password: "");
//            }

        listener(NetworkChannel(preferences,
            detectIRCNetworkChannelType(parsed.chan.type), parsed.chan.id));
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
        var message = toIRCMessage(data.msg);
        if (data.unread != null) {
          var channelState = currentStateExtractor();
          channelState.unreadCount = data.unread;
          listener(channelState);
        }

//            listener(message);
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

        var request = _oldRequests.firstWhere((request) {
          var loungeJsonRequest =
              request as LoungeJsonRequest<NetworkNewLoungeRequestBody>;
          if (loungeJsonRequest != null) {
            return true;
          } else {
            return false;
          }
        }, orElse: () => null)
            as LoungeJsonRequest<NetworkNewLoungeRequestBody>;

        var loungePreferences = request.body;

        // todo retreive settings from request
        var connectionPreferences = IRCNetworkConnectionPreferences(
            serverPreferences: IRCNetworkServerPreferences(
                name: loungeNetwork.name,
                serverHost: loungeNetwork.host,
                serverPort: loungeNetwork.port.toString(),
                useTls: true,
                useOnlyTrustedCertificates: true),
            userPreferences: IRCNetworkUserPreferences(
                nickname: loungeNetwork.nick,
                realName: loungeNetwork.realname,
                username: loungeNetwork.username));

        var channels = <NetworkChannel>[];

        for (var loungeChannel in loungeNetwork.channels) {
          channels.add(NetworkChannel(
              IRCNetworkChannelPreferences.name(
                  name: loungeChannel.name, password: ""),
              detectIRCNetworkChannelType(loungeChannel.type),
              loungeChannel.id));
        }

        listener(Network(connectionPreferences, loungeNetwork.uuid, channels));
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
    // TODO: implement listenForNetworkState
    var disposable = CompositeDisposable([]);

    return disposable;

//    var parsed =
//    NetworkOptionsLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _networkOptionsController.sink.add(parsed);

//    var parsed =
//    NetworkStatusLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _networkStatusController.sink.add(parsed);
    return null;
  }

  @override
  Future<RequestResult<bool>> onOpenNetworkChannel(
      Network network, NetworkChannel channel) async {
    _sendRequest(LoungeRawRequest(
        name: LoungeRequestEventNames.open, body: [channel.remoteId]));
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<List<IRCChatSpecialMessage>>>
      printNetworkAvailableChannels(Network network,
          {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/channellist");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkChannelMessage>> printNetworkChannelBannedUsers(
      Network network, NetworkChannel channel,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, channel, "/ignorelist");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkChannelMessage>> printNetworkIgnoredUsers(
      Network network,
      {bool waitForResult = false}) async {
    if (waitForResult) {
      throw NotImplementedYetException();
    }
    _sendInputRequest(network, network.lobbyChannel, "/ignorelist");
    return RequestResult.name(isSentSuccessfully: true, result: null);
  }

  @override
  Future<RequestResult<NetworkChannelMessage>> sendNetworkChannelRawMessage(
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
    return null;
  }

  _sendRequest(LoungeRequest request) async {
    _oldRequests.add(request);
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

  void _sendInputRequest(
      Network network, NetworkChannel channel, String message) {
    _sendRequest(LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: InputLoungeRequestBody(
            target: channel.remoteId, content: message)));
  }
}
