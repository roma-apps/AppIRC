import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/provider/provider.dart';


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

buildChannelUnreadCountBadge(BuildContext context) {

  var channelBloc = Provider.of<NetworkChannelBloc>(context);

  return StreamBuilder<NetworkChannelState>(
    stream: channelBloc.networkChannelStateStream,
    initialData: channelBloc.networkChannelState,
    builder: (BuildContext context, AsyncSnapshot<NetworkChannelState> snapshot) {
      var state = snapshot.data;

      var unreadCount = state.unreadCount;
      if (unreadCount != null && unreadCount > 0) {
        return _buildChannelUnreadBadgeCount(context, unreadCount);
      } else {
        return Container();
      }
    },
  );
}
