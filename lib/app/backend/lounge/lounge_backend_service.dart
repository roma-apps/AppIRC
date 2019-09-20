import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/manager.dart';
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
import 'package:flutter_appirc/socketio/socketio_model.dart';
import 'package:flutter_appirc/socketio/socketio_service.dart';

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

  final List<LoungeRequest> _oldRequests = [];

  LoungeBackendService(this.socketIOManager, this._loungePreferences) {
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
  }

  bool get isConnected => connectionState == ChatConnectionState.CONNECTED;

  @override
  Stream<ChatConnectionState> get connectionStateStream =>
      _socketIOService.connectionStateStream.map(mapState);

  ChatConnectionState get connectionState =>
      mapState(_socketIOService.connectionState);

  Future<RequestResult<bool>> tryConnectWithDifferentPreferences(
      LoungeConnectionPreferences preferences) async {
    SocketIOService socketIOService;
    var connected = false;
    try {
      socketIOService = SocketIOService(socketIOManager, preferences.host);
      await socketIOService.init();
      var chatConfig =  await _connect(preferences, socketIOService);
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

    var chatConfig = await _connect(_loungePreferences, _socketIOService);

    if (chatConfig != null) {
      this.chatConfig = chatConfig;
      return RequestResult(true, true);
    } else {
      return RequestResult(true, false);
    }
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

  void _sendInputRequest(
      Network network, NetworkChannel channel, String message) {
    _sendRequest(LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: InputLoungeRequestBody(
            target: channel.remoteId, content: message)));
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

  _logger.d(()=> "start connect to $preferences");
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
  disposable.add(
      _listenForAuth(socketIOService, () => authReceived = true));
  disposable.add(
      _listenForCommands(socketIOService, (result) => loungeCommands = result));

  Future.delayed(_connectTimeout, () => timeout = true);

  await socketIOService.connect();
  // lounge don't support connect/connecting callbacks
  // TODO: should be changed if lounge will start support it
  var socketConnected = true;

  _logger.d(()=> "_connect socketConnected= $socketConnected");

  if(socketConnected) {
    while ((loungeCommands == null && loungeConfig == null ||
        authorizedReceived == false) &&
        !timeout && authReceived == false) {
      await Future.delayed(_timeBetweenCheckingConnectionResponse);
    }
  }


  disposable.dispose();


  var commandsReceived = loungeCommands != null;
  var configReceived = loungeConfig != null;

  _logger.d(()=> "_connect commandsReceived = $commandsReceived "
      "configReceived = $configReceived authorizedReceived = $authorizedReceived, authReceived = $authReceived");

  if (socketConnected) {

    if(authReceived) {
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
        socketIOService.disconnect();
        if (!commandsReceived && !configReceived && !authorizedReceived) {
          return null;
        } else {
          // something received something not
          throw InvalidConnectionResponseException(
              preferences, authorizedReceived, configReceived, commandsReceived);
        }


      }
    }
  } else {
    return null;
  }
}
