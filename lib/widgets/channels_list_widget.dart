import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/pages/new_connection_page.dart';

class ChannelsListWidget extends StatelessWidget {
  final bool isNeedDisplayNewChannelRow;

  ChannelsListWidget({this.isNeedDisplayNewChannelRow = true});

  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);

    return StreamBuilder<List<Channel>>(
        stream: chatBloc.outChannels,
        builder: (BuildContext context, AsyncSnapshot<List<Channel>> snapshot) {
          var listItemCount = _calculateListItemCount(snapshot);
          return ListView.builder(
              itemCount: listItemCount,
              itemBuilder: (BuildContext context, int index) {
                if (_isNewChannelButton(listItemCount, index)) {
                  return _newConnectionButton(context);
                } else {
                  return _listItem(context, chatBloc, snapshot.data[index]);
                }
              });
        });
  }

  Widget _listItem(BuildContext context, ChatBloc chatBloc, Channel channel) {
    return InkWell(
      onTap: () {
        chatBloc.changeActiveChanel(channel);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(channel.name,
                  style: _chooseTextStyleForChannel(context, channel))),
        ],
      ),
    );
  }

  bool _isNewChannelButton(int listItemCount, int currentIndex) =>
      isNeedDisplayNewChannelRow && currentIndex == listItemCount - 1;

  Widget _newConnectionButton(BuildContext context) =>
      RaisedButton(
        child: Text("New connetion"),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NewConnectionPage()));
        },
      );

  int _calculateListItemCount(AsyncSnapshot<List<Channel>> snapshot) {
    var snapshotCount = (snapshot.data == null ? 0 : snapshot.data.length);
    var itemsCount =
    isNeedDisplayNewChannelRow ? snapshotCount + 1 : snapshotCount;
    return itemsCount;
  }

  _chooseTextStyleForChannel(BuildContext context, Channel channel) {
    var theme = Theme.of(context);
    return channel.isActive ? theme.textTheme.caption : theme.textTheme.body1;
  }
}
