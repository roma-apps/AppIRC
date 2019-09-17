import 'package:adhara_socket_io/manager.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';

class LoungeBackendService extends ChatBackendService {
  final SocketIOManager socketIOManager;
  final LoungePreferences loungePreferences;

  Stream<bool> get connectedStream => lounge.connectedStream;

  bool get isConnected  =>  lounge.isConnected;


  LoungeService lounge;

  LoungeBackendService(this.socketIOManager, this.loungePreferences)
  {
    lounge = LoungeService(socketIOManager);
  }


  @override
  void dispose() {
    lounge.dispose();

  }

  Future<bool> tryConnect(LoungePreferences preferences) async {
    var loungeService = LoungeService(socketIOManager);
    var connected = await loungeService.connect(preferences);

    loungeService.disconnect();

    return connected;
  }

  Future<bool> connect() => lounge.connect(loungePreferences);


}
