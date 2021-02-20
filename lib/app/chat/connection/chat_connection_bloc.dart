import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/provider/provider.dart';


class ChatConnectionBloc extends Providable {
  final ChatBackendService backendService;

  bool get isConnected => backendService.isConnected;
  Stream<bool> get isConnectedStream => backendService.isConnectedStream;

  ChatConnectionState get connectionState => backendService.connectionState;

  Stream<ChatConnectionState> get connectionStateStream =>
      backendService.connectionStateStream;

  ChatConnectionBloc(this.backendService) {
//    addDisposable(
//        timer: Timer.periodic(_reconnectDuration, (_) => _reconnectIfNeeded()));
    Timer.run(() {
      _reconnectIfNeeded();
    });

    addDisposable(
        streamSubscription:
            connectionStateStream.listen((newBackendState) async {}));
  }

  Future reconnect() => _reconnectIfNeeded();

  Future _reconnectIfNeeded() async {
//    _logger.d(() => "_reconnectIfNeeded = $connectionState "
//        "backendService.isReadyToConnect = ${backendService.isReadyToConnect}");
    if (connectionState == ChatConnectionState.disconnected) {
      var connectivityResult = await (Connectivity().checkConnectivity());

      var connected;
      switch (connectivityResult) {
        case ConnectivityResult.wifi:
          connected = true;
          break;
        case ConnectivityResult.mobile:
          connected = true;
          break;
        case ConnectivityResult.none:
          connected = false;
          break;
      }
      if (connected) {
        if (backendService.isReadyToConnect) {
          await backendService.connectChat();
        }
      }
    }
  }
}
