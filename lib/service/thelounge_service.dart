import 'package:flutter_appirc/blocs/bloc.dart';
import 'package:flutter_appirc/models/socketio_model.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';
import 'package:flutter_appirc/service/socketio_service.dart';

class TheLoungeService extends BlocBase {
  SocketIOService socketIOService;

  TheLoungeService(this.socketIOService);


  networkNew(NetworkNewTheLoungeRequestBody body) async {
    await _sendCommand(TheLoungeRequest("network:new", body));
  }

  _sendCommand(TheLoungeRequest request) async {
    await socketIOService.emit(request);
  }

  connect() async {
    socketIOService.connect();
  }

  disconnect() async {
    socketIOService.disconnect();
  }

  isConnected() => socketIOService.isProbablyConnected;

  @override
  void dispose() {
    // TODO: implement dispose
  }
}