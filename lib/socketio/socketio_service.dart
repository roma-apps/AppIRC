import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/socketio/socketio_model.dart';

class SocketIOService {
  final SocketIOManager _manager;
  final String uri;

  SocketIOService(this._manager, this.uri);

  SocketIO _socketIO;
  bool isProbablyConnected;

  void on(String type, SocketEventListener listener) =>
      _socketIO.on(type, listener);


  void onConnect(SocketEventListener listener) =>
      _socketIO.onConnect(listener);

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


  void onError(SocketEventListener listener) =>
      _socketIO.onError(listener);


  void onPing(SocketEventListener listener) =>
      _socketIO.onPing(listener);


  void onPong(SocketEventListener listener) =>
      _socketIO.onPong(listener);


  void offConnect(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECT, listener);

  void offDisconnect(SocketEventListener listener) =>
      _socketIO.off(SocketIO.DISCONNECT, listener);


  void offConnecting(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECTING,listener);

  void offConnectError(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECT_ERROR,listener);
  void offConnectTimeout(SocketEventListener listener) =>
      _socketIO.off(SocketIO.CONNECT_TIMEOUT, listener);

  void offReconnect(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECT,listener);


  void offReconnectError(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECT_ERROR,listener);


  void offReconnectFailed(SocketEventListener listener) =>
      _socketIO.off(SocketIO.RECONNECT_FAILED,listener);


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

   init() async {
    _socketIO = await _manager.createInstance(SocketOptions(
        //Socket IO server URI
        uri,
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET,
          Transports.POLLING
        ] //Enable required transport
        ));
  }

  connect() async {
    isProbablyConnected = true;
    return await _socketIO.connect();
  }

  emit(SocketIOCommand command) async =>
      await _socketIO.emit(command.getName(), command.getBody());

  disconnect() async {
    isProbablyConnected = false;
    return await _manager.clearInstance(_socketIO);
 
  }
}
