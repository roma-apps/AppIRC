import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/pages/chat_page.dart';
import 'package:flutter_appirc/widgets/new_connection_widget.dart';

class NewConnectionPage extends StatelessWidget {
  bool isOpenedFromAppStart;

  NewConnectionPage({this.isOpenedFromAppStart = false});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('new_connection.title')),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: NewConnectionWidget(() {
                    if (isOpenedFromAppStart) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ChatPage()));
                    } else {
                      Navigator.pop(context);
                    }
                  })),
            ],
          );
        },
      ),
    );
  }
}
