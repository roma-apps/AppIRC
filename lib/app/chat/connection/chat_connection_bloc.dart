import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:logging/logging.dart';

final _logger = Logger("chat_connection_bloc.dart");

class ChatConnectionBloc extends DisposableOwner {
  final ChatBackendService backendService;

  bool get isConnected => backendService.isConnected;

  Stream<bool> get isConnectedStream => backendService.isConnectedStream;

  ChatConnectionState get connectionState => backendService.connectionState;

  Stream<ChatConnectionState> get connectionStateStream =>
      backendService.connectionStateStream;

  ChatConnectionBloc(this.backendService) {
    Timer.run(() {
      _reconnectIfNeeded();
    });

    addDisposable(
      streamSubscription: connectionStateStream.listen(
        (newBackendState) async {},
      ),
    );
  }

  Future reconnect() => _reconnectIfNeeded();

  Future _reconnectIfNeeded() async {
   _logger.fine(() => "_reconnectIfNeeded = $connectionState "
       "backendService.isReadyToConnect = ${backendService.isReadyToConnect}");
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
