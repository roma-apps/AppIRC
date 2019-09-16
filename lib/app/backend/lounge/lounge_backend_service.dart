import 'package:adhara_socket_io/manager.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';

class LoungeBackendService extends ChatBackendService {
  final SocketIOManager socketIOManager;
  final LoungePreferences loungePreferences;

  LoungeBackendService(this.socketIOManager, this.loungePreferences);


  @override
  void dispose() {

  }

  Future<bool> tryConnect(LoungePreferences preferences) async {
    var loungeService = LoungeService(socketIOManager);
    var connected = await loungeService.connect(loungePreferences);

    loungeService.disconnect();

    return connected;
  }

}