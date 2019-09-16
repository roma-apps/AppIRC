import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/socketio_service.dart';
import 'package:rxdart/rxdart.dart';

class LoungeResponseEventNames {
  static const String network = "network";
  static const String nick = "nick";
  static const String msg = "msg";
  static const String configuration = "configuration";
  static const String authorized = "authorized";
  static const String commands = "commands";
  static const String topic = "topic";
  static const String names = "names";
  static const String users = "users";
  static const String join = "join";
  static const String part = "part";
  static const String networkStatus = "network:status";
  static const String networkOptions = "network:options";
  static const String channelStateOptions = "channel:state";
}

class LoungeRequestEventNames {
  static const String networkNew = "network:new";
  static const String input = "input";
}

var _logger = MyLogger(logTag: "LoungeService", enabled: true);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);
const _timeoutForRequestsWithResponse = Duration(seconds: 10);
const _timeBetweenCheckResultForRequestsWithResponse =
    Duration(milliseconds: 100);
const _timeBetweenCheckAnotherRequestInProgress = Duration(milliseconds: 100);

class LoungeService extends Providable {
  bool requestWithResultInProgress = false;

  SocketIOManager socketIOManager;
  SocketIOService socketIOService;

  LoungeService(this.socketIOManager);

  BehaviorSubject<LoungePreferences> _loungePreferencesController =
      new BehaviorSubject<LoungePreferences>();

  Stream<LoungePreferences> get loungePreferencesStream =>
      _loungePreferencesController.stream;

  ReplaySubject<MessageLoungeResponseBody> _messagesController =
      new ReplaySubject<MessageLoungeResponseBody>();

  BehaviorSubject<NickLoungeResponseBody> _nickController =
      new BehaviorSubject<NickLoungeResponseBody>();

  Stream<MessageLoungeResponseBody> get messagesStream =>
      _messagesController.stream;

  var _networksController = new BehaviorSubject<
      LoungeResultForRequest<LoungeJsonRequest<NetworkNewLoungeRequestBody>,
          NetworksLoungeResponseBody>>();

  Stream<
      LoungeResultForRequest<LoungeJsonRequest<NetworkNewLoungeRequestBody>,
          NetworksLoungeResponseBody>> get networksStream =>
      _networksController.stream;

  BehaviorSubject<ConfigurationLoungeResponseBody> _configurationController =
      new BehaviorSubject<ConfigurationLoungeResponseBody>();

  Stream<ConfigurationLoungeResponseBody> get configurationStream =>
      _configurationController.stream;

  BehaviorSubject<NamesLoungeResponseBody> _namesController =
      new BehaviorSubject<NamesLoungeResponseBody>();

  Stream<NamesLoungeResponseBody> get namesStream => _namesController.stream;

  BehaviorSubject<UsersLoungeResponseBody> _usersController =
      new BehaviorSubject<UsersLoungeResponseBody>();

  Stream<UsersLoungeResponseBody> get usersStream => _usersController.stream;

  BehaviorSubject<JoinLoungeResponseBody> _joinController =
      new BehaviorSubject<JoinLoungeResponseBody>();

  Stream<JoinLoungeResponseBody> get joinStream => _joinController.stream;

  var _joinToRequestController = new BehaviorSubject<
      LoungeResultForRequest<
          LoungeJsonRequest<InputLoungeRequestBody<JoinIRCCommand>>,
          JoinLoungeResponseBody>>();

  Stream<
      LoungeResultForRequest<
          LoungeJsonRequest<InputLoungeRequestBody<JoinIRCCommand>>,
          JoinLoungeResponseBody>> get joinToRequestStream =>
      _joinToRequestController.stream;

  var _closeToRequestController = new BehaviorSubject<
      LoungeResultForRequest<
          LoungeJsonRequest<InputLoungeRequestBody<CloseIRCCommand>>,
          ChanLoungeResponseBody>>();

  Stream<
      LoungeResultForRequest<
          LoungeJsonRequest<InputLoungeRequestBody<CloseIRCCommand>>,
          ChanLoungeResponseBody>> get closeToRequestStream =>
      _closeToRequestController.stream;


  BehaviorSubject<NetworkStatusLoungeResponseBody> _networkStatusController =
      new BehaviorSubject<NetworkStatusLoungeResponseBody>();

  Stream<NetworkStatusLoungeResponseBody> get networkStatusStream =>
      _networkStatusController.stream;

  BehaviorSubject<NetworkOptionsLoungeResponseBody> _networkOptionsController =
      new BehaviorSubject<NetworkOptionsLoungeResponseBody>();

  Stream<NetworkOptionsLoungeResponseBody> get networkOptionsStream =>
      _networkOptionsController.stream;

  BehaviorSubject<ChannelStateLoungeResponseBody> _channelStateController =
      new BehaviorSubject<ChannelStateLoungeResponseBody>();

  Stream<ChannelStateLoungeResponseBody> get channelStateStream =>
      _channelStateController.stream;

  BehaviorSubject _authorizedController = new BehaviorSubject();

  Stream get outAuthorized => _configurationController.stream;

  BehaviorSubject<List<String>> _commandsController =
      new BehaviorSubject<List<String>>();

  Stream<List<String>> get commandsStream => _commandsController.stream;

  BehaviorSubject<TopicLoungeResponseBody> _topicController =
      new BehaviorSubject<TopicLoungeResponseBody>();

  Stream<TopicLoungeResponseBody> get topicStream => _topicController.stream;

  bool get isProbablyConnected =>
      socketIOService != null && socketIOService.isProbablyConnected;

  _sendRequest(LoungeRequest request) async {
    _logger.d(() => "_sendCommand $request");
    return await socketIOService.emit(request);
  }

  Future<K> _sendRequestWithResult<T extends LoungeRequest, K>(
      {@required T request,
      String resultEventName,
      @required K resultParser(dynamic),
      Duration timeout = _timeoutForRequestsWithResponse}) async {
    _logger.d(() => "_sendCommandWithResult start $request"
        " resultEventName $resultEventName"
        " requestWithResultInProgress = $requestWithResultInProgress");

    var timeout = false;

    // setup timeout
    Future.delayed(_timeoutForRequestsWithResponse, () {
      timeout = true;
    });

    // avoid several requests with result in one time
    while (requestWithResultInProgress && !timeout) {
      await Future.delayed(_timeBetweenCheckAnotherRequestInProgress, () {});
    }
    var resultRaw;

    if (!timeout) {
      var resultHandler = (raw) {
        _logger.d(() => "resultHandler $raw");
        resultRaw = raw;
      };

      socketIOService.on(resultEventName, resultHandler);

      await socketIOService.emit(request);

      // wait for response or timeout
      while (timeout != true && resultRaw == null) {
        await Future.delayed(
            _timeBetweenCheckResultForRequestsWithResponse, () {});
      }

      socketIOService.off(resultEventName, resultHandler);
    }

    if (timeout == true) {
      throw RequestWithResultTimeoutLoungeException(request);
    } else {
      return resultParser(resultRaw);
    }
  }

  Future<bool> connect(LoungePreferences preferences) async {
    _logger.i(() => "start connecting to $preferences");
    if (isProbablyConnected) {
      throw AlreadyConnectedLoungeException();
    }

    socketIOService = SocketIOService(socketIOManager, preferences.host);
    _logger.i(() => "start init socket service");
    await socketIOService.init();
    _addSubscriptions();

    var connected = false;
    var responseReceived = false;

    Exception connectionException;

    var connectListener = (_) {
      _logger.i(() => "connecting onConnect");
      connected = true;
      responseReceived = true;
    };
    socketIOService.onConnect(connectListener);

    var connectErrorListener = (value) {
      _logger.e(() => "connecting onConnectError $value");
      connectionException = ConnectionErrorLoungeException(value);
      responseReceived = true;
    };
    socketIOService.onConnectError(connectErrorListener);
    var connectTimeoutListener = (value) {
      _logger.e(() => "connecting onConnectTimeout $value");
      connectionException = ConnectionTimeoutLoungeException();
      responseReceived = true;
    };
    socketIOService.onConnectTimeout(connectTimeoutListener);

    _logger.i(() => "start socket connect");
    await socketIOService.connect();

    while (!responseReceived) {
      await Future.delayed(_timeBetweenCheckingConnectionResponse);
    }

    _logger.i(() => "finish connecting connected = $connected");

    socketIOService.offConnect(connectListener);
    socketIOService.offConnectTimeout(connectTimeoutListener);
    socketIOService.offConnectError(connectErrorListener);

    if (connectionException != null) {
      disconnect();
      throw connectionException;
    }

    if (connected) {
      _loungePreferencesController.add(preferences);
    }

    return connected;
  }

  disconnect() async {
    _removeSubscriptions();
    if (isProbablyConnected) {
      var result = await socketIOService.disconnect();

      socketIOService = null;
      return result;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _topicController.close();
    _messagesController.close();
    _networksController.close();
    _authorizedController.close();
    _configurationController.close();
    _commandsController.close();
    _namesController.close();
    _usersController.close();
    _joinController.close();
    _networkOptionsController.close();
    _networkStatusController.close();
    _channelStateController.close();
    _nickController.close();
    _closeToRequestController.close();

    _loungePreferencesController.close();

    _joinToRequestController.close();

    disconnect();
  }

  sendOpenRequest(IRCNetworkChannel channel) async => await _sendRequest(
      LoungeRawRequest(name: "open", body: [channel.remoteId]));

  sendNamesRequest(IRCNetworkChannel channel) async =>
      await _sendRequest(LoungeJsonRequest(
          name: "names",
          body: NamesLoungeRequestBody(target: channel.remoteId)));

  Future<
      LoungeResultForRequest<LoungeJsonRequest<NetworkNewLoungeRequestBody>,
          NetworksLoungeResponseBody>> sendNewNetworkRequest(
      IRCNetworkPreferences channelConnectionInfo) async {
    var networkConnectionPreferences =
        channelConnectionInfo.networkConnectionPreferences;

    var networkPreferences = networkConnectionPreferences.serverPreferences;
    var userPreferences = networkConnectionPreferences.userPreferences;

    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.networkNew,
        body: NetworkNewLoungeRequestBody(
          username: userPreferences.username,
          nick: userPreferences.nickname,
          join: channelConnectionInfo.notLobbyChannelsString,
          realname: userPreferences.realName,
          password: userPreferences.password,
          host: networkPreferences.serverHost,
          port: networkPreferences.serverPort,
          rejectUnauthorized: networkPreferences.useOnlyTrustedCertificates
              ? loungeOn
              : loungeOff,
          tls: networkPreferences.useTls ? loungeOn : loungeOff,
          name: networkPreferences.name,
        ));

    var result = await _sendRequestWithResult(
        request: request,
        resultEventName: LoungeResponseEventNames.network,
        resultParser: (raw) =>
            NetworksLoungeResponseBody.fromJson(_preProcessRawData(raw)));

    if (result != null) {
      var loungeResultForRequest = LoungeResultForRequest(request, result);
      _networksController.add(loungeResultForRequest);
      return loungeResultForRequest;
    } else {
      return null;
    }
  }

  sendChatMessageRequest(int remoteChannelId, String text) async =>
      await _sendRequest(LoungeJsonRequest(
          name: LoungeRequestEventNames.input,
          body: MessageInputLoungeRequestBody(
              body: text, target: remoteChannelId)));

  void _addSubscriptions() {
    socketIOService.onConnect((_) {
      sendSettingsGetRequest();
    });

//    socketIOService.on(LoungeResponseEventNames.network, _onNetworkResponse);
    socketIOService.on(LoungeResponseEventNames.msg, _onMessageResponse);
    socketIOService.on(LoungeResponseEventNames.nick, _onNickResponse);
    socketIOService.on(LoungeResponseEventNames.topic, _onTopicResponse);
    socketIOService.on(
        LoungeResponseEventNames.configuration, _onConfigurationResponse);
    socketIOService.on(
        LoungeResponseEventNames.authorized, _onAuthorizedResponse);
    socketIOService.on(LoungeResponseEventNames.commands, _onCommandResponse);
    socketIOService.on(LoungeResponseEventNames.names, _onNamesResponse);
    socketIOService.on(LoungeResponseEventNames.users, _onUsersResponse);
    socketIOService.on(LoungeResponseEventNames.join, _onJoinResponse);
    socketIOService.on(
        LoungeResponseEventNames.networkStatus, _onNetworkStatusResponse);
    socketIOService.on(
        LoungeResponseEventNames.networkOptions, _onNetworkOptionsResponse);
    socketIOService.on(
        LoungeResponseEventNames.channelStateOptions, _onChannelStateResponse);
  }

  void _removeSubscriptions() {
//    socketIOService.off(LoungeResponseEventNames.network, _onNetworkResponse);
    socketIOService.off(LoungeResponseEventNames.msg, _onMessageResponse);
    socketIOService.off(LoungeResponseEventNames.nick, _onNickResponse);
    socketIOService.off(LoungeResponseEventNames.topic, _onTopicResponse);
    socketIOService.off(
        LoungeResponseEventNames.configuration, _onConfigurationResponse);
    socketIOService.off(
        LoungeResponseEventNames.authorized, _onAuthorizedResponse);
    socketIOService.off(LoungeResponseEventNames.commands, _onCommandResponse);
    socketIOService.off(LoungeResponseEventNames.names, _onNamesResponse);
    socketIOService.off(LoungeResponseEventNames.users, _onUsersResponse);
    socketIOService.off(LoungeResponseEventNames.join, _onJoinResponse);
    socketIOService.off(
        LoungeResponseEventNames.networkStatus, _onNetworkStatusResponse);
    socketIOService.off(
        LoungeResponseEventNames.networkOptions, _onNetworkOptionsResponse);
    socketIOService.off(
        LoungeResponseEventNames.channelStateOptions, _onChannelStateResponse);
  }

  void _onTopicResponse(raw) {
    _logger.i(() => "_onTopicResponse $raw");
    var data = TopicLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _topicController.sink.add(data);
  }

  void _onMessageResponse(raw) {
    _logger.i(() => "_onMessageResponse $raw");
    var data = MessageLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _messagesController.sink.add(data);
  }

  void _onNickResponse(raw) {
    _logger.i(() => "_onNickResponse $raw");
    var data = NickLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _nickController.sink.add(data);
  }

  void _onConfigurationResponse(raw) {
    var parsed =
        ConfigurationLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _configurationController.sink.add(parsed);
  }

  void _onAuthorizedResponse(raw) {
    _authorizedController.sink.add(null);
  }

  void _onCommandResponse(raw) {
    _logger.i(() => "_onCommandResponse $raw");
//    var parsed = raw;
//    _commandsController.sink.add(parsed);
  }

  void _onNamesResponse(raw) {
    var parsed = NamesLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _namesController.sink.add(parsed);
  }

  void _onUsersResponse(raw) {
    var parsed = UsersLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _usersController.sink.add(parsed);
  }

  void _onJoinResponse(raw) {
    var parsed = JoinLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _joinController.sink.add(parsed);
  }

  void _onNetworkStatusResponse(raw) {
    var parsed =
        NetworkStatusLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _networkStatusController.sink.add(parsed);
  }

  void _onNetworkOptionsResponse(raw) {
    var parsed =
        NetworkOptionsLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _networkOptionsController.sink.add(parsed);
  }

  void _onChannelStateResponse(raw) {
    var parsed =
        ChannelStateLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _channelStateController.sink.add(parsed);
  }

//  void _onNetworkResponse(raw) {
//    var parsed = NetworksLoungeResponseBody.fromJson(_preProcessRawData(raw));
//    _logger.i(() => "_onNetworkResponse parsed $parsed");
//    _networksController.sink.add(parsed);
//  }

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

  sendSettingsGetRequest() async =>
      await _sendRequest(LoungeRawRequest(name: "setting:get"));

  sendJoinChannelMessageRequest(
      IRCNetworkChannel targetChannel, JoinIRCCommand ircCommand) async {
    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: CommandInputLoungeRequestBody(
            body: ircCommand, target: targetChannel.remoteId));

    var result = await _sendRequestWithResult(
        request: request,
        resultEventName: LoungeResponseEventNames.join,
        resultParser: (raw) =>
            JoinLoungeResponseBody.fromJson(_preProcessRawData(raw)));

    if (result != null) {
      var loungeResultForRequest = LoungeResultForRequest(request, result);
      _joinToRequestController.add(loungeResultForRequest);
      return loungeResultForRequest;
    } else {
      return null;
    }
  }


  sendCloseChannelMessageRequest(
      IRCNetworkChannel targetChannel, CloseIRCCommand ircCommand) async {
    var request = LoungeJsonRequest(
        name: LoungeRequestEventNames.input,
        body: CommandInputLoungeRequestBody(
            body: ircCommand, target: targetChannel.remoteId));

    var result = await _sendRequestWithResult(
        request: request,
        resultEventName: LoungeResponseEventNames.part,
        resultParser: (raw) =>
            ChanLoungeResponseBody.fromJson(_preProcessRawData(raw)));

    if (result != null) {
      var loungeResultForRequest = LoungeResultForRequest(request, result);
      _closeToRequestController.add(loungeResultForRequest);
      return loungeResultForRequest;
    } else {
      return null;
    }
  }
}
