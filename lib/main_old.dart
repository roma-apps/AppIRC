import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';

import 'service/log_service.dart';

void main() {
  runApp(MyApp());
}

const String URI = "http://192.168.0.103:9000/";
//const String URI = "https://demo.thelounge.chat/";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final nicknameController = TextEditingController();
  final channelController = TextEditingController();

  List<String> toPrint = ["trying to conenct"];
  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  Map<String, bool> _isProbablyConnected = {};

  @override
  void initState() {
    super.initState();
    manager = SocketIOManager();

    nicknameController.text = "CustomNickname";
    channelController.text = "#thelounge";

    initSocket("default");
  }

  initSocket(String identifier) async {
    setState(() => _isProbablyConnected[identifier] = true);
    SocketIO socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        URI,
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
    sockets[identifier] = socket;
  }

  bool isProbablyConnected(String identifier) {
    return _isProbablyConnected[identifier] ?? false;
  }

  disconnect(String identifier) async {
    await manager.clearInstance(sockets[identifier]);
    setState(() => _isProbablyConnected[identifier] = false);
  }

  sendMessage(identifier) {
    if (sockets[identifier] != null) {
      pprint("sending message from '$identifier'...");
      sockets[identifier].emit("network:new", [
        {
          "host": "chat.freenode.net",
          "join": channelController.text,
          "name": "Freenode",
          "nick": nicknameController.text,
          "port": "6697",
          "realname": "The Lounge User",
          "rejectUnauthorized": "on",
          "tls": "on",
          "username": "thelounge"
        }
      ]);

      pprint("Message emitted from '$identifier'...");
    }
  }

  Container getButtonSet(String identifier) {
    bool ipc = isProbablyConnected(identifier);
    return Container(
      height: 80.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: RaisedButton(
              child: Text("Connect"),
              onPressed: ipc ? null : () => initSocket(identifier),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: RaisedButton(
                child: Text("Login"),
                onPressed: ipc ? () => sendMessage(identifier) : null,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: RaisedButton(
                child: Text("Disconnect"),
                onPressed: ipc ? () => disconnect(identifier) : null,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          textTheme: TextTheme(
            title: TextStyle(color: Colors.white),
            headline: TextStyle(color: Colors.white),
            subtitle: TextStyle(color: Colors.white),
            subhead: TextStyle(color: Colors.white),
            body1: TextStyle(color: Colors.white),
            body2: TextStyle(color: Colors.white),
            button: TextStyle(color: Colors.white),
            caption: TextStyle(color: Colors.white),
            overline: TextStyle(color: Colors.white),
            display1: TextStyle(color: Colors.white),
            display2: TextStyle(color: Colors.white),
            display3: TextStyle(color: Colors.white),
            display4: TextStyle(color: Colors.white),
          ),
          buttonTheme: ButtonThemeData(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
              disabledColor: Colors.lightBlueAccent.withOpacity(0.5),
              buttonColor: Colors.lightBlue,
              splashColor: Colors.cyan)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AppIRC 2'),
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        body: LogConsoleOnShake(
          dark: true,
          child: Container(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Center(
                  child: ListView(
                    children: toPrint.map((String _) => Text(_ ?? "")).toList(),
                  ),
                )),
                Padding(
                  padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Freenode Connection",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style:
                        new TextStyle(fontSize: 22.0, color: Color(0xFFbdc6cf)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    controller: nicknameController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style:
                        new TextStyle(fontSize: 22.0, color: Color(0xFFbdc6cf)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    controller: channelController,
                  ),
                ),
                getButtonSet("default"),
                SizedBox(
                  height: 12.0,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
