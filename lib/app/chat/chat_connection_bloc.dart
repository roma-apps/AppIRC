import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

var reconnectDuration = Duration(seconds: 5);

class ChatConnectionBloc extends Providable {
  final ChatInputOutputBackendService backendService;

  ChatConnectionBloc(this.backendService) {

  }

  bool get isConnected => backendService.isConnected;

  ChatConnectionState get connectionState => backendService.connectionState;

  Stream<ChatConnectionState> get connectionStateStream =>
      backendService.connectionStateStream;

  Future<RequestResult<bool>> connectToBackend() async =>
      backendService.connectChat();

  reconnect() => _reconnectIfNeeded();

  void _reconnectIfNeeded() async {
//    _logger.d(() => "_reconnectIfNeeded = $connectionState");
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
        backendService.connectChat();
      }
    }
  }

  Future init() async {
    addDisposable(
        timer: Timer.periodic(reconnectDuration, (_) => _reconnectIfNeeded()));

    _reconnectIfNeeded();
  }
}