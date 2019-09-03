import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/bloc.dart';
import 'package:flutter_appirc/blocs/connections_bloc.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';
import 'package:flutter_appirc/pages/chat_page.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';

class NewConnectionPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final TheLoungeService loungeService =
        BlocProvider.of<TheLoungeService>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('New Connection'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: RaisedButton(
              child: Text("Connect"),
              onPressed: () {
                loungeService.networkNew(NetworkNewTheLoungeRequestBody(
                    "chat.freenode.net",
                    "#thelounge-spam",
                    "Freenode",
                    "TheLounge123",
                    "6697",
                    "The Lounge User",
                    "on",
                    "on",
                    "thelounge"));

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
              padding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
          ),
        ],
      ),
    );
  }
}