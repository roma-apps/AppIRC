import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/pages/join_channel_page.dart';
import 'package:flutter_appirc/pages/irc_connection_page.dart';
import 'package:flutter_appirc/provider.dart';

class ChannelsListWidget extends StatelessWidget {
  final bool isNeedDisplayNewConnectionRow;

  ChannelsListWidget({this.isNeedDisplayNewConnectionRow = true});

  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);

    var networksListWidget = StreamBuilder<List<Network>>(
        stream: chatBloc.outNetworks,
        builder: (BuildContext context, AsyncSnapshot<List<Network>> snapshot) {
          var listItemCount = (snapshot.data == null ? 0 : snapshot.data
              .length);

          return Container(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: listItemCount,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      child:
                      _networkItem(context, chatBloc, snapshot.data[index])
                  );
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

  Widget _channelItem(BuildContext context, ChatBloc chatBloc,
      Channel channel) {
    return StreamBuilder<Channel>(
        builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
          var isActive = channel == snapshot.data;
          if (isActive) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(8.0),
                      child: Text(channel.name,
                          style: Theme
                              .of(context)
                              .textTheme
                              .title))
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

  Widget _networkItem(BuildContext context, ChatBloc chatBloc,
      Network network) {
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
                Text(network.name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .title),
                IconButton(icon: Icon(Icons.add), onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => JoinChannelPage(network)));
                },)
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

  Widget _newConnectionButton(BuildContext context) =>
      RaisedButton(
        child: Text(
            AppLocalizations.of(context).tr('chat.channels.new_connection')),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => IRCConnectionPage()));
        },
      );


}
