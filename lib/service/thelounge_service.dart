import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/socketio_service.dart';
import 'package:rxdart/rxdart.dart';

const String _logTag = "TheLoungeService";

const String _networkLoungeEvent = "network";
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

const timeoutForPingInSeconds = 30;

class TheLoungeService extends Providable {
  static const String defaultLoungeHost = "https://demo.thelounge.chat/";

  String host = defaultLoungeHost;

  SocketIOManager socketIOManager;
  SocketIOService socketIOService;

  Timer _pingTimer;

  bool _latestPongWasZero = false;

  TheLoungeService(this.socketIOManager);

  ReplaySubject<MessageTheLoungeResponseBody> _messagesController =
      new ReplaySubject<MessageTheLoungeResponseBody>();

  Stream<MessageTheLoungeResponseBody> get outMessages =>
      _messagesController.stream;

  BehaviorSubject<NetworksTheLoungeResponseBody> _networksController =
      new BehaviorSubject<NetworksTheLoungeResponseBody>();

  Stream<NetworksTheLoungeResponseBody> get outNetworks =>
      _networksController.stream;

  BehaviorSubject<ConfigurationTheLoungeResponseBody> _configurationController =
  new BehaviorSubject<ConfigurationTheLoungeResponseBody>();

  Stream<ConfigurationTheLoungeResponseBody> get outConfiguration =>
      _configurationController.stream;

  BehaviorSubject<NamesTheLoungeResponseBody> _namesController =
  new BehaviorSubject<NamesTheLoungeResponseBody>();

  Stream<NamesTheLoungeResponseBody> get outNames =>
      _namesController.stream;
  
  BehaviorSubject<UsersTheLoungeResponseBody> _usersController =
  new BehaviorSubject<UsersTheLoungeResponseBody>();

  Stream<UsersTheLoungeResponseBody> get outUsers =>
      _usersController.stream;

  BehaviorSubject<JoinTheLoungeResponseBody> _joinController =
  new BehaviorSubject<JoinTheLoungeResponseBody>();

  Stream<JoinTheLoungeResponseBody> get outJoin =>
      _joinController.stream;


  BehaviorSubject<NetworkStatusTheLoungeResponseBody> _networkStatusController =
  new BehaviorSubject<NetworkStatusTheLoungeResponseBody>();

  Stream<NetworkStatusTheLoungeResponseBody> get outNetworkStatus =>
      _networkStatusController.stream;



  BehaviorSubject<NetworkOptionsTheLoungeResponseBody> _networkOptionsController =
  new BehaviorSubject<NetworkOptionsTheLoungeResponseBody>();

  Stream<NetworkOptionsTheLoungeResponseBody> get outNetworkOptions =>
      _networkOptionsController.stream;



  BehaviorSubject<ChannelStateTheLoungeResponseBody> _channelStateController =
  new BehaviorSubject<ChannelStateTheLoungeResponseBody>();

  Stream<ChannelStateTheLoungeResponseBody> get outChannelState =>
      _channelStateController.stream;



  BehaviorSubject _authorizedController =
  new BehaviorSubject();

  Stream get outAuthorized =>
      _configurationController.stream;


  BehaviorSubject<List<String>> _commandsController =
  new BehaviorSubject<List<String>>();

  Stream<List<String>> get outCommands =>
      _commandsController.stream;


  BehaviorSubject<TopicTheLoungeResponseBody> _topicController =
  new BehaviorSubject<TopicTheLoungeResponseBody>();

  Stream<TopicTheLoungeResponseBody> get outTopic =>
      _topicController.stream;

  bool get isProbablyConnected => socketIOService != null && socketIOService.isProbablyConnected;


  _sendCommand(TheLoungeRequest request) async {
    await socketIOService.emit(request);
  }

  connect() async {


    socketIOService = SocketIOService(socketIOManager, host);
    await socketIOService.init();
    _addSubscriptions();
    await socketIOService.connect();
    retrieveSettings();

    _pingTimer = Timer.periodic(Duration(seconds: timeoutForPingInSeconds), (timer) {
      ping();
      pong();
    });
  }

  disconnect() async {


    _removeSubscriptions();
    socketIOService.disconnect();
    socketIOService = null;
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
    _pingTimer.cancel();

    disconnect();
  }

  void ping() {
    _sendCommand(TheLoungeRawRequest(name: "ping"));

  }

  void pong() {
    _sendCommand(TheLoungeRawRequest(name: "pong", body: [
      _latestPongWasZero ? 0 : 1
    ])); // I am not sure what is just emulate behaviour
    _latestPongWasZero = !_latestPongWasZero;
  }

  void open(Channel channel) {
    _sendCommand(TheLoungeRawRequest(name: "open", body: [channel.remoteId]));
  }

  void names(Channel channel) {
    _sendCommand(TheLoungeRawRequest(name: "names", body: [channel.remoteId]));
  }

  Future newNetwork(ChannelsConnectionInfo channelConnectionInfo) async {
    if(!isProbablyConnected) {
      await connect();
    }

    var networkPreferences = channelConnectionInfo.networkPreferences;
    var userPreferences = channelConnectionInfo.userPreferences;
    await _sendCommand(TheLoungeJsonRequest(
        name: "network:new",
        body: NetworkNewTheLoungeRequestBody(
          username: userPreferences.username,
          nick: userPreferences.nickname,
          join: channelConnectionInfo.channels,
          realname: userPreferences.realName,
          password: userPreferences.password,
          host: networkPreferences.serverHost,
          port: networkPreferences.serverPort,
          rejectUnauthorized: networkPreferences.useOnlyTrustedCertificates
              ? theLoungeOn
              : theLoungeOff,
          tls: networkPreferences.useTls ? theLoungeOn : theLoungeOff,
        )));
  }

  void sendChatMessage(int remoteChannelId, String text) =>
      _sendCommand(TheLoungeJsonRequest(
          name: "input",
          body:
              InputTheLoungeRequestBody(text: text, target: remoteChannelId)));

  void _addSubscriptions() {
    socketIOService.subscribe(_networkLoungeEvent, _onNetworkResponse);
    socketIOService.subscribe(_msgLoungeEvent, _onMessageResponse);
    socketIOService.subscribe(_topicLoungeEvent, _onTopicResponse);
    socketIOService.subscribe(_configurationLoungeEvent, _onConfigurationResponse);
    socketIOService.subscribe(_authorizedLoungeEvent, _onAuthorizedResponse);
    socketIOService.subscribe(_commandsLoungeEvent, _onCommandResponse);
    socketIOService.subscribe(_namesLoungeEvent, _onNamesResponse);
    socketIOService.subscribe(_usersLoungeEvent, _onUsersResponse);
    socketIOService.subscribe(_joinLoungeEvent, _onJoinResponse);
    socketIOService.subscribe(_networkStatusLoungeEvent, _onNetworkStatusResponse);
    socketIOService.subscribe(_networkOptionsLoungeEvent, _onNetworkOptionsResponse);
    socketIOService.subscribe(_channelStateOptionsLoungeEvent, _onChannelStateResponse);
  }

  void _removeSubscriptions() {
    socketIOService.unsubscribe(_networkLoungeEvent, _onNetworkResponse);
    socketIOService.unsubscribe(_msgLoungeEvent, _onMessageResponse);
    socketIOService.unsubscribe(_topicLoungeEvent, _onTopicResponse);
    socketIOService.unsubscribe(_configurationLoungeEvent, _onConfigurationResponse);
    socketIOService.unsubscribe(_authorizedLoungeEvent, _onAuthorizedResponse);
    socketIOService.unsubscribe(_commandsLoungeEvent, _onCommandResponse);
    socketIOService.unsubscribe(_namesLoungeEvent, _onNamesResponse);
    socketIOService.unsubscribe(_usersLoungeEvent, _onUsersResponse);
    socketIOService.unsubscribe(_joinLoungeEvent, _onJoinResponse);
    socketIOService.unsubscribe(_networkStatusLoungeEvent, _onNetworkStatusResponse);
    socketIOService.unsubscribe(_networkOptionsLoungeEvent, _onNetworkOptionsResponse);
    socketIOService.unsubscribe(_channelStateOptionsLoungeEvent, _onChannelStateResponse);
  }


  void _onTopicResponse(raw) {
    logi(_logTag, "_onTopicResponse $raw");
    var data = TopicTheLoungeResponseBody.fromJson(raw);
    _topicController.sink.add(data);
  }

  void _onMessageResponse(raw) {
    logi(_logTag, raw);
    var data = MessageTheLoungeResponseBody.fromJson(raw);
    _messagesController.sink.add(data);
  }


  void _onConfigurationResponse(raw) {
    var parsed = ConfigurationTheLoungeResponseBody.fromJson(raw);
    _configurationController.sink.add(parsed);
  }

  void _onAuthorizedResponse(raw) {
    _authorizedController.sink.add(null);
  }


  void _onCommandResponse(raw) {
//    var parsed = raw;
//    _commandsController.sink.add(parsed);
  }


  void _onNamesResponse(raw) {
    var parsed = NamesTheLoungeResponseBody.fromJson(raw);
    _namesController.sink.add(parsed);
  }


  void _onUsersResponse(raw) {
    var parsed = UsersTheLoungeResponseBody.fromJson(raw);
    _usersController.sink.add(parsed);
  }


  void _onJoinResponse(raw) {
    var parsed = JoinTheLoungeResponseBody.fromJson(raw);
    _joinController.sink.add(parsed);
  }
  void _onNetworkStatusResponse(raw) {
    var parsed = NetworkStatusTheLoungeResponseBody.fromJson(raw);
    _networkStatusController.sink.add(parsed);
  }


  void _onNetworkOptionsResponse(raw) {
    var parsed = NetworkOptionsTheLoungeResponseBody.fromJson(raw);
    _networkOptionsController.sink.add(parsed);
  }

  void _onChannelStateResponse(raw) {
    var parsed = ChannelStateTheLoungeResponseBody.fromJson(raw);
    _channelStateController.sink.add(parsed);
  }

  void _onNetworkResponse(raw) {
    logi(_logTag, "_onNetworkResponse raw $raw");
    var parsed = NetworksTheLoungeResponseBody.fromJson(raw);
    _networksController.sink.add(parsed);
  }

  void retrieveSettings() {
    _sendCommand(TheLoungeRawRequest(name: "setting:get"));
  }
}
