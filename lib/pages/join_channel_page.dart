import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/widgets/join_channel_widget.dart';

class JoinChannelPage extends StatefulWidget {
  final Network network;


  JoinChannelPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return JoinChannelPageState(network);
  }
}

class JoinChannelPageState extends State<JoinChannelPage> {
  Network network;


  JoinChannelPageState(this.network);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('join_channel.title')),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: JoinChannelFormWidget(network, () {
                      Navigator.pop(context);
                  })),
            ],
          );
        },
      ),
    );
  }
}
