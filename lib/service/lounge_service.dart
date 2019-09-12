import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/socketio_service.dart';
import 'package:rxdart/rxdart.dart';


const String _networkLoungeEvent = "network";
const String _nickLoungeEvent = "nick";
const String _msgLoungeEvent = "msg";
const String _configurationLoungeEvent = "configuration";
const String _authorizedLoungeEvent = "authorized";
const String _commandsLoungeEvent = "commands";
const String _topicLoungeEvent = "topic";
const String _namesLoungeEvent = "names";
const String _usersLoungeEvent = "users";
const String _joinLoungeEvent = "join";
const String _networkStatusLoungeEvent = "network:status";
const String _networkOptionsLoungeEvent = "network:options";
const String _channelStateOptionsLoungeEvent = "channel:state";

var _logger = MyLogger(logTag: "LoungeService", enabled: true);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);

class LoungeService extends Providable {
  SocketIOManager socketIOManager;
  SocketIOService socketIOService;

  LoungeService(this.socketIOManager);

  ReplaySubject<MessageLoungeResponseBody> _messagesController =
      new ReplaySubject<MessageLoungeResponseBody>();

  BehaviorSubject<NickLoungeResponseBody> _nickController =
      new BehaviorSubject<NickLoungeResponseBody>();

  Stream<MessageLoungeResponseBody> get messagesStream =>
      _messagesController.stream;

  BehaviorSubject<NetworksLoungeResponseBody> _networksController =
      new BehaviorSubject<NetworksLoungeResponseBody>();

  Stream<NetworksLoungeResponseBody> get networksStream =>
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

  _sendCommand(LoungeRequest request) async {
    _logger.d(()=>"_sendCommand $request");
    return await socketIOService.emit(request);
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

    return connected;
  }

  disconnect() async {
    _removeSubscriptions();
    var result = await socketIOService.disconnect();
    socketIOService = null;
    return result;
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

    disconnect();
  }

  sendOpenRequest(IRCNetworkChannel channel) async => await _sendCommand(
      LoungeRawRequest(name: "open", body: [channel.remoteId]));

  sendNamesRequest(IRCNetworkChannel channel) async => await _sendCommand(
      LoungeJsonRequest(name: "names", body: NamesLoungeRequestBody(target: channel.remoteId)));

  sendNewNetworkRequest(IRCNetworkPreferences channelConnectionInfo) async {
    var networkPreferences = channelConnectionInfo.serverPreferences;
    var userPreferences = channelConnectionInfo.userPreferences;
    await _sendCommand(LoungeJsonRequest(
        name: "network:new",
        body: NetworkNewLoungeRequestBody(
          username: userPreferences.username,
          nick: userPreferences.nickname,
          join: userPreferences.channels.join(" "),
          realname: userPreferences.realName,
          password: userPreferences.password,
          host: networkPreferences.serverHost,
          port: networkPreferences.serverPort,
          rejectUnauthorized: networkPreferences.useOnlyTrustedCertificates
              ? loungeOn
              : loungeOff,
          tls: networkPreferences.useTls ? loungeOn : loungeOff,
        )));
  }

  sendChatMessageRequest(int remoteChannelId, String text) async =>
      await _sendCommand(LoungeJsonRequest(
          name: "input",
          body: InputLoungeRequestBody(text: text, target: remoteChannelId)));

  void _addSubscriptions() {
    socketIOService.onConnect((_) {
      sendSettingsGetRequest();
    });

    socketIOService.on(_networkLoungeEvent, _onNetworkResponse);
    socketIOService.on(_msgLoungeEvent, _onMessageResponse);
    socketIOService.on(_nickLoungeEvent, _onNickResponse);
    socketIOService.on(_topicLoungeEvent, _onTopicResponse);
    socketIOService.on(_configurationLoungeEvent, _onConfigurationResponse);
    socketIOService.on(_authorizedLoungeEvent, _onAuthorizedResponse);
    socketIOService.on(_commandsLoungeEvent, _onCommandResponse);
    socketIOService.on(_namesLoungeEvent, _onNamesResponse);
    socketIOService.on(_usersLoungeEvent, _onUsersResponse);
    socketIOService.on(_joinLoungeEvent, _onJoinResponse);
    socketIOService.on(_networkStatusLoungeEvent, _onNetworkStatusResponse);
    socketIOService.on(_networkOptionsLoungeEvent, _onNetworkOptionsResponse);
    socketIOService.on(
        _channelStateOptionsLoungeEvent, _onChannelStateResponse);
  }

  void _removeSubscriptions() {
    socketIOService.off(_networkLoungeEvent, _onNetworkResponse);
    socketIOService.off(_msgLoungeEvent, _onMessageResponse);
    socketIOService.off(_nickLoungeEvent, _onNickResponse);
    socketIOService.off(_topicLoungeEvent, _onTopicResponse);
    socketIOService.off(_configurationLoungeEvent, _onConfigurationResponse);
    socketIOService.off(_authorizedLoungeEvent, _onAuthorizedResponse);
    socketIOService.off(_commandsLoungeEvent, _onCommandResponse);
    socketIOService.off(_namesLoungeEvent, _onNamesResponse);
    socketIOService.off(_usersLoungeEvent, _onUsersResponse);
    socketIOService.off(_joinLoungeEvent, _onJoinResponse);
    socketIOService.off(_networkStatusLoungeEvent, _onNetworkStatusResponse);
    socketIOService.off(_networkOptionsLoungeEvent, _onNetworkOptionsResponse);
    socketIOService.off(
        _channelStateOptionsLoungeEvent, _onChannelStateResponse);
  }

  void _onTopicResponse(raw) {
    _logger.i(() =>"_onTopicResponse $raw");
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

  void _onNetworkResponse(raw) {
    var parsed = NetworksLoungeResponseBody.fromJson(_preProcessRawData(raw));
    _logger.i(() => "_onNetworkResponse parsed $parsed");
    _networksController.sink.add(parsed);
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

  sendSettingsGetRequest() async =>
      await _sendCommand(LoungeRawRequest(name: "setting:get"));
}
