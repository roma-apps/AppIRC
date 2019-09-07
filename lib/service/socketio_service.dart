import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/models/socketio_model.dart';

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
      _socketIO.off(SocketIO.DISCONNECT,listener);

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
    
//    _socketIO.on("network", (data) => pprint("type:network | $data"));
//    _socketIO.on("*", (data) => pprint("type:all | $data"));
    

//    socket.onConnect((data) {
//      pprint("connected...");
//      pprint(data);
//    });
//    socket.onConnectError(pprint);
//    socket.onConnectTimeout(pprint);
//    socket.onError(pprint);
//    socket.onDisconnect(pprint);
//    socket.on("type:string", (data) => pprint("type:string | $data"));
//    socket.on("type:bool", (data) => pprint("type:bool | $data"));
//    socket.on("type:number", (data) => pprint("type:number | $data"));
//    socket.on("type:object", (data) => pprint("type:object | $data"));
//    socket.on("type:list", (data) => pprint("type:list | $data"));
//    socket.on("message", (data) => pprint(data));
//    socket.on("configuration", (data) => pprint("type:configuration | $data"));
//    socket.on("authorized", (data) => pprint("type:authorized | $data"));
//    socket.on("init", (data) => pprint("type:init | $data"));
//    socket.on("commands", (data) => pprint("type:commands | $data"));

//    socket.on("msg", (data) => pprint("type:msg | $data"));
//    socket.on("open", (data) => pprint("type:open | $data"));
//    socket.on("names", (data) => pprint("type:names | $data"));
//    socket.on("topic", (data) => pprint("topic | $data"));
//    socket.on("users", (data) => pprint("users | $data"));
//    socket.on("join", (data) => pprint("join | $data"));
//    socket.on(
//        "network:status", (data) => pprint("type:network:status | $data"));
//    socket.on("channel:state", (data) => pprint("channel:state | $data"));
  }

  emit(SocketIOCommand command) async =>
      await _socketIO.emit(command.getName(), command.getBody());

  disconnect() async {
    isProbablyConnected = false;
    return await _manager.clearInstance(_socketIO);
 
  }
}
