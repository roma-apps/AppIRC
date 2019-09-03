import 'dart:convert';
import 'package:flutter_appirc/blocs/connections_bloc.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';
import 'package:flutter_appirc/pages/new_connection_page.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';

import 'blocs/bloc.dart';
import 'service/log_service.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'service/socketio_service.dart';



const String URI = "https://demo.thelounge.chat/";
var socketIOManager = SocketIOManager();
var socketIOService = SocketIOService(socketIOManager, URI);
var loungeService = TheLoungeService(socketIOService);


void main() {
  loungeService.connect();
  LogConsole.init(bufferSize: 100);
  runApp(AppIRC());

}

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: loungeService,
      child: BlocProvider<ConnectionsBloc>(
          bloc: ConnectionsBloc(),
          child: MaterialApp(
            title: 'App IRC',
            theme: ThemeData(
              primarySwatch: Colors.red,
            ),
            home: NewConnectionPage(),
          )
      ),
    );
  }
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final nicknameController = TextEditingController();
  final channelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    nicknameController.text = "CustomNickname";
    channelController.text = "#thelounge";

    initSocket();
  }

  initSocket() {
    loungeService.connect();
  }

  disconnect() async {
    loungeService.disconnect();
  }

  sendMessage() {
    loungeService.networkNew(NetworkNewTheLoungeRequestBody(
        "chat.freenode.net",
        channelController.text,
        "Freenode",
        nicknameController.text,
        "6697",
        "The Lounge User",
        "on",
        "on",
        "thelounge"));

    pprint("sendMessage");
  }

  Container getButtonSet(String identifier) {
    return Container(
      height: 80.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: RaisedButton(
              child: Text("Connect"),
              onPressed:
              loungeService.isConnected() ? null : () => initSocket(),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: RaisedButton(
                child: Text("Login"),
                onPressed: loungeService.isConnected()
                    ? () => sendMessage()
                    : null,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: RaisedButton(
                child: Text("Disconnect"),
                onPressed: loungeService.isConnected()
                    ? () => disconnect()
                    : null,
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
//                Expanded(
//                    child: Center(
//                  child: ListView(
//                    children: toPrint.map((String _) => Text(_ ?? "")).toList(),
//                  ),
//                )),
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
