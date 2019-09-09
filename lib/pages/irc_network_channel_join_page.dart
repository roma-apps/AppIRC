import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_join_widget.dart';

class IRCNetworkChannelJoinPage extends StatefulWidget {
  final IRCNetwork network;

  IRCNetworkChannelJoinPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return IRCNetworkChannelJoinPageState(network);
  }
}

class IRCNetworkChannelJoinPageState extends State<IRCNetworkChannelJoinPage> {
  final IRCNetwork network;

  IRCNetworkChannelJoinPageState(this.network);

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
                  child: IRCNetworkChannelJoinWidget(network, () {
                    Navigator.pop(context);
                  })),
            ],
          );
        },
      ),
    );
  }
}
