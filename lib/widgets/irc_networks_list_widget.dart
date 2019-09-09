import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_chat_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/pages/irc_network_channel_join_page.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/helpers/provider.dart';

class IRCNetworksListWidget extends StatelessWidget {
  final bool isNeedDisplayNewConnectionRow;

  IRCNetworksListWidget({this.isNeedDisplayNewConnectionRow = true});

  @override
  Widget build(BuildContext context) {
    var chatBloc = Provider.of<IRCChatBloc>(context);

    var networksListWidget = StreamBuilder<List<IRCNetwork>>(
        stream: chatBloc.networksStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<IRCNetwork>> snapshot) {
          var listItemCount =
              (snapshot.data == null ? 0 : snapshot.data.length);

          return Container(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: listItemCount,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      child: _networkItem(
                          context, chatBloc, snapshot.data[index]));
                }),
          );
        });

    if (isNeedDisplayNewConnectionRow) {
      return ListView(children: <Widget>[
        networksListWidget,
        _newConnectionButton(context)
      ]);
    } else {
      return networksListWidget;
    }
  }

  Widget _channelItem(
      BuildContext context, IRCChatBloc chatBloc, IRCNetworkChannel channel) {
    return StreamBuilder<IRCNetworkChannel>(builder:
        (BuildContext context, AsyncSnapshot<IRCNetworkChannel> snapshot) {
      var isActive = channel == snapshot.data;
      if (isActive) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(8.0),
                  child: Text(channel.name,
                      style: Theme.of(context).textTheme.title))
            ]);
      } else {
        return InkWell(
          onTap: () {
            chatBloc.changeActiveChanel(channel);
          },
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(8.0), child: Text(channel.name))
              ]),
        );
      }
    });
  }

  Widget _networkItem(
      BuildContext context, IRCChatBloc chatBloc, IRCNetwork network) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(network.name, style: Theme.of(context).textTheme.title),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                IRCNetworkChannelJoinPage(network)));
                  },
                )
              ],
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: network.channels.length,
                itemBuilder: (BuildContext context, int index) {
                  return _channelItem(
                      context, chatBloc, network.channels[index]);
                })
          ]),
    );
  }

  Widget _newConnectionButton(BuildContext context) => RaisedButton(
        child: Text(
            AppLocalizations.of(context).tr('chat.channels.new_connection')),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => IRCNetworksNewConnectionPage()));
        },
      );
}
