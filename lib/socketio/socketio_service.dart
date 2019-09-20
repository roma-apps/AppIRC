import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/main.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/socketio/socketio_model.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "SocketIOService", enabled: true);

var _connectTimeout = Duration(seconds: 5);
const _timeBetweenCheckingConnectionResponse = Duration(milliseconds: 500);

class SocketIOService extends Providable {
  final SocketIOManager _manager;
  final String uri;

  // ignore: close_sinks
  BehaviorSubject<SocketConnectionState> _connectionStateController =
      BehaviorSubject(seedValue: SocketConnectionState.DISCONNECTED);

  Stream<SocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  SocketConnectionState get connectionState => _connectionStateController.value;

  SocketIOService(this._manager, this.uri) {
    addDisposable(subject: _connectionStateController);
  }

  SocketIO _socketIO;

  void on(String type, SocketEventListener listener) =>
      _socketIO.on(type, listener);

  void onConnect(SocketEventListener listener) => _socketIO.onConnect(listener);

  void onDisconnect(SocketEventListener listener) =>
      _socketIO.onDisconnect(listener);

  void onConnecting(SocketEventListener listener) =>
      _socketIO.onConnecting(listener);

  void onConnectError(SocketEventListener listener) =>
      _socketIO.onConnectError(listener);

  void onConnectTimeout(SocketEventListener listener) =>
      _socketIO.onConnectTimeout(listener);

  void onReconnect(SocketEventListener listener) =>
      _socketIO.onReconnect(listener);

  void onReconnectError(SocketEventListener listener) =>
      _socketIO.onReconnectError(listener);

  void onReconnectFailed(SocketEventListener listener) =>
      _socketIO.onReconnectFailed(listener);

  void onReconnecting(SocketEventListener listener) =>
      _socketIO.onReconnecting(listener);

  void onError(SocketEventListener listener) => _socketIO.onError(listener);

  void onPing(SocketEventListener listener) => _socketIO.onPing(listener);

  void onPong(SocketEventListener listener) => _socketIO.onPong(listener);

  void offConnect(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECT, listener);

  void offDisconnect(SocketEventListener listener) =>
      _socketIO.off(SocketIO.DISCONNECT, listener);

  void offConnecting(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECTING, listener);

  void offConnectError(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECT_ERROR, listener);

  void offConnectTimeout(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECT_TIMEOUT, listener);

  void offReconnect(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECT, listener);

  void offReconnectError(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECT_ERROR, listener);

  void offReconnectFailed(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECT_FAILED, listener);

  void offReconnecting(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECTING, listener);

  void offError(SocketEventListener listener) =>
      _socketIO.off(SocketIO.ERROR, listener);

  void offPing(SocketEventListener listener) =>
      _socketIO.off(SocketIO.PING, listener);

  void offPong(SocketEventListener listener) =>
      _socketIO.off(SocketIO.PONG, listener);

  void off(String type, SocketEventListener listener) =>
      _socketIO.off(type, listener);

  Future init() async {
    _socketIO = await socketIOManager.createInstance(_createSocketOptions(uri));

    addDisposable(
        disposable: _listenConnectionState(
            (state) => _connectionStateController.add(state)));
  }

  Disposable _listenConnectionState(
      void Function(SocketConnectionState) listener) {
    SocketEventListener connectListener =
        (_) => listener(SocketConnectionState.CONNECTED);
    SocketEventListener disconnectListener =
        (_) => listener(SocketConnectionState.DISCONNECTED);
    SocketEventListener connectErrorListener =
        (_) => listener(SocketConnectionState.DISCONNECTED);
    SocketEventListener connectTimeoutListener =
        (_) => listener(SocketConnectionState.DISCONNECTED);
    SocketEventListener connectingListener =
        (_) => listener(SocketConnectionState.CONNECTING);
    SocketEventListener reconnectListener =
        (_) => listener(SocketConnectionState.CONNECTED);
    SocketEventListener reconnectFailedListener =
        (_) => listener(SocketConnectionState.DISCONNECTED);
    SocketEventListener reconnectErrorListener =
        (_) => listener(SocketConnectionState.DISCONNECTED);
    SocketEventListener reconnectingListener =
        (_) => listener(SocketConnectionState.CONNECTING);
    onConnect(connectListener);
    onDisconnect(disconnectListener);
    onConnectError(connectErrorListener);
    onConnectTimeout(connectTimeoutListener);
    onConnecting(connectingListener);
    onReconnect(reconnectListener);
    onReconnectFailed(reconnectFailedListener);
    onReconnectError(reconnectErrorListener);
    onReconnecting(reconnectingListener);

    return CustomDisposable(() {
      offConnect(connectListener);
      offDisconnect(disconnectListener);
      offConnectError(connectErrorListener);
      offConnectTimeout(connectTimeoutListener);
      offConnecting(connectingListener);
      offReconnect(reconnectListener);
      offReconnectFailed(reconnectFailedListener);
      offReconnectError(reconnectErrorListener);
      offReconnecting(reconnectingListener);
    });
  }

  connect() async {
    return await _socketIO.connect();
  }

  Future<bool> connectAndWaitForResult() async => await _connect(_socketIO);

  emit(SocketIOCommand command) async =>
      await _socketIO.emit(command.getName(), command.getBody());

  disconnect() async {
    return await _manager.clearInstance(_socketIO);
  }

  SocketOptions _createSocketOptions(String host) {
    return SocketOptions(
        //Socket IO server URI
        host,
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET,
          Transports.POLLING
        ] //Enable required transport
        );
  }

  Future _connect(SocketIO socketIO) async {
    var connected;
    var connectListener = (_) {
      connected = true;
    };

    var errorListener = (_) {
      connected = false;
    };

    try {
      socketIO.on(SocketIO.CONNECT, connectListener);
      socketIO.on(SocketIO.CONNECT_ERROR, errorListener);
      socketIO.on(SocketIO.CONNECT_TIMEOUT, errorListener);
      await socketIO.connect();

      // library timeout sometimes not works
      Future.delayed(_connectTimeout, () {
        if (connected == null) {
          connected = false;
        }
      });
    } finally {
      if (socketIO != null) {
        socketIO.off(SocketIO.CONNECT, connectListener);
        socketIO.off(SocketIO.CONNECT_ERROR, errorListener);
        socketIO.off(SocketIO.CONNECT_TIMEOUT, errorListener);
      }
    }

    while (connected == null) {
      await Future.delayed(_timeBetweenCheckingConnectionResponse);
    }
    return connected;
  }
}
