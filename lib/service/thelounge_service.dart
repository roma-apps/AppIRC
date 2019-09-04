import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/socketio_service.dart';
import 'package:rxdart/rxdart.dart';

class TheLoungeService extends Providable {
  SocketIOService socketIOService;

  TheLoungeService(this.socketIOService);

  BehaviorSubject<MessageTheLoungeResponseBody> _messagesController =
      new BehaviorSubject<MessageTheLoungeResponseBody>();

  Stream<MessageTheLoungeResponseBody> get outMessages =>
      _messagesController.stream;

  BehaviorSubject<NetworksTheLoungeResponseBody> _networksController =
      new BehaviorSubject<NetworksTheLoungeResponseBody>();

  Stream<NetworksTheLoungeResponseBody> get outNetworks =>
      _networksController.stream;

  _sendCommand(TheLoungeRequest request) async {
    await socketIOService.emit(request);
  }

  connect() async {
    _addSubscriptions();
    socketIOService.connect();
  }

  disconnect() async {
    _removeSubscriptions();
    socketIOService.disconnect();
  }

  @override
  void dispose() {
    _messagesController.close();
    _networksController.close();
    disconnect();
  }

  void newNetwork(ChannelsConnectionInfo channelConnectionInfo) {
    var networkPreferences = channelConnectionInfo.networkPreferences;
    var userPreferences = channelConnectionInfo.userPreferences;
    _sendCommand(TheLoungeRequest(
        "network:new",
        NetworkNewTheLoungeRequestBody(
          username: userPreferences.nickname,
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
      _sendCommand(TheLoungeRequest("input",
          InputTheLoungeRequestBody(text: text, target: remoteChannelId)));

  void _addSubscriptions() {
    socketIOService.subscribe("network", _onNetworkResponse);
    socketIOService.subscribe("msg", _onMessageResponse);
  }

  void _removeSubscriptions() {
    socketIOService.unsubscribe("network", _onNetworkResponse);
    socketIOService.unsubscribe("msg", _onMessageResponse);
  }

  void _onMessageResponse(messageResponse) {
    var data = MessageTheLoungeResponseBody.fromJson(messageResponse);
    logger.d(data);
    _messagesController.sink.add(data);
  }

  void _onNetworkResponse(networkResponse) {
    var data = NetworksTheLoungeResponseBody.fromJson(networkResponse);
    logger.d(data);
    _networksController.sink.add(data);
  }
}
