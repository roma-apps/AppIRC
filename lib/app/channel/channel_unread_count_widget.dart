import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

import 'channels_list_skin_bloc.dart';


Widget _buildChannelUnreadBadgeCount(BuildContext context, bool isChannelActive, int unreadCount) {
  if (unreadCount > 0) {
    var channelSkinBloc = Provider.of<ChannelsListSkinBloc>(context);
    return Container(
        decoration: BoxDecoration(color: channelSkinBloc.getChannelUnreadItemBackgroundColor(isChannelActive)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(unreadCount.toString(), style: channelSkinBloc.getChannelUnreadTextStyle(isChannelActive)),
        ));
  } else {
    return Container();
  }
}

buildChannelUnreadCountBadge(BuildContext context, bool isChannelActive) {

  var channelBloc = Provider.of<NetworkChannelBloc>(context);

  return StreamBuilder<NetworkChannelState>(
    stream: channelBloc.networkChannelStateStream,
    initialData: channelBloc.networkChannelState,
    builder: (BuildContext context, AsyncSnapshot<NetworkChannelState> snapshot) {
      var state = snapshot.data;

      var unreadCount = state.unreadCount;
      if (unreadCount != null && unreadCount > 0) {
        return _buildChannelUnreadBadgeCount(context, isChannelActive, unreadCount);
      } else {
        return Container();
      }
    },
  );
}
