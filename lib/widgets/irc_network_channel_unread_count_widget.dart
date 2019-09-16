import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_unread_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

Widget _buildChannelUnreadBadgeCount(BuildContext context, int unreadCount) {
  if (unreadCount > 0) {
    return Container(
        decoration: BoxDecoration(color: Colors.redAccent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(unreadCount.toString(), style: TextStyle(color: Colors.white),),
        ));
  } else {
    return Container();
  }
}

buildChannelUnreadCountBadge(LoungeService lounge, IRCNetworkChannel channel) {
  var unreadBloc = IRCNetworkChannelUnreadCountBloc(lounge, channel);

  return StreamBuilder<int>(
    stream: unreadBloc.unreadCountStream,
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
      var unreadCount = snapshot.data;
      if (unreadCount != null && unreadCount > 0) {
        return _buildChannelUnreadBadgeCount(context, unreadCount);
      } else {
        return Container();
      }
    },
  );
}
