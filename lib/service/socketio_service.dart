import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/models/socketio_model.dart';

import 'log_service.dart';

class SocketIOService {
  final SocketIOManager manager;
  final String uri;

  SocketIOService(this.manager, this.uri);

  SocketIO socketIO;
  bool isProbablyConnected;

  void connect() async {
    isProbablyConnected = true;
    SocketIO socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        uri,
        //Query params - can be used for authentication
        query: {
          "auth": "--SOME AUTH STRING---",
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET,
          Transports.POLLING
        ] //Enable required transport
        ));

    socket.onConnect((data) {
      pprint("connected...");
      pprint(data);
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect(pprint);
    socket.on("type:string", (data) => pprint("type:string | $data"));
    socket.on("type:bool", (data) => pprint("type:bool | $data"));
    socket.on("type:number", (data) => pprint("type:number | $data"));
    socket.on("type:object", (data) => pprint("type:object | $data"));
    socket.on("type:list", (data) => pprint("type:list | $data"));
    socket.on("message", (data) => pprint(data));
    socket.on("configuration", (data) => pprint("type:configuration | $data"));
    socket.on("authorized", (data) => pprint("type:authorized | $data"));
    socket.on("init", (data) => pprint("type:init | $data"));
    socket.on("commands", (data) => pprint("type:commands | $data"));
    socket.on("network", (data) => pprint("type:network | $data"));
    socket.on("msg", (data) => pprint("type:msg | $data"));
    socket.on("open", (data) => pprint("type:open | $data"));
    socket.on("names", (data) => pprint("type:names | $data"));
    socket.on("topic", (data) => pprint("topic | $data"));
    socket.on("users", (data) => pprint("users | $data"));
    socket.on("join", (data) => pprint("join | $data"));
    socket.on(
        "network:status", (data) => pprint("type:network:status | $data"));
    socket.on("channel:state", (data) => pprint("channel:state | $data"));

    socket.connect();
    this.socketIO = socket;
  }

  emit(SocketIOCommand command) async {
    await socketIO.emit(command.getName(), command.getBody());
  }

  disconnect() async {
    await manager.clearInstance(socketIO);
    isProbablyConnected = false;
  }
//  sendMessage(SocketIOCommand socketIoCommand) async {
//
//  }
}
