import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/state/chat_connection_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _reconnectDuration = Duration(seconds: 5);


class ChatConnectionBloc extends Providable {
  final ChatInputOutputBackendService backendService;


  bool get isConnected => backendService.isConnected;

  ChatConnectionState get connectionState => backendService.connectionState;

  Stream<ChatConnectionState> get connectionStateStream =>
      backendService.connectionStateStream;


  ChatConnectionBloc(this.backendService) {
    addDisposable(
        timer: Timer.periodic(_reconnectDuration, (_) => _reconnectIfNeeded()));
    // TODO: extract constant
    Future.delayed(Duration(milliseconds: 100), () {
      _reconnectIfNeeded();
    });



  }


  reconnect() => _reconnectIfNeeded();

  void _reconnectIfNeeded() async {
//    _logger.d(() => "_reconnectIfNeeded = $connectionState "
//        "backendService.isReadyToConnect = ${backendService.isReadyToConnect}");
    if (connectionState == ChatConnectionState.DISCONNECTED) {
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
        if(backendService.isReadyToConnect) {
          backendService.connectChat();
        }

      }
    }
  }

}
