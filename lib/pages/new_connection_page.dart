import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/blocs/new_connection_bloc.dart';
import 'package:flutter_appirc/pages/chat_page.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/widgets/new_connection_widget.dart';

class NewConnectionPage extends StatefulWidget {
  final bool isOpenedFromAppStart;

  NewConnectionPage({this.isOpenedFromAppStart = false});

  @override
  State<StatefulWidget> createState() {
    return NewConnectionState(isOpenedFromAppStart);
  }
}

class NewConnectionState extends State<NewConnectionPage> {
  final bool isOpenedFromAppStart;

  NewConnectionState(this.isOpenedFromAppStart);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);
    var newConnectionBloc = NewConnectionBloc(chatBloc);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('new_connection.title')),
      ),
      body: Column(
        children: <Widget>[
          Provider<NewConnectionBloc>(
            bloc: newConnectionBloc,
            child: Expanded(
              child: ListView(shrinkWrap: true, children: _buildForms()),
            ),
          ),
          RaisedButton(
            child: Text(
                AppLocalizations.of(context).tr('new_connection.connect')),
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            onPressed: () {
              newConnectionBloc.addConnectionToChat();
              if (isOpenedFromAppStart) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ChatPage()));
              } else {
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
    );
  }

  List<Widget> _buildForms() {
    if(isOpenedFromAppStart) {
      return <Widget>[
        LoungePreferencesConnectionFormWidget(),
        NetworkPreferencesConnectionFormWidget(),
        UserPreferencesConnectionFormWidget()
      ];
    } else {
      return <Widget>[
        NetworkPreferencesConnectionFormWidget(),
        UserPreferencesConnectionFormWidget()
      ];
    }

  }
}
