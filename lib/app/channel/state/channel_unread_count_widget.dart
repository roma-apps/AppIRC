import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/list/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

Widget _buildChannelUnreadBadgeCount(
    BuildContext context, bool isChannelActive, int unreadCount) {
  if (unreadCount > 0) {
    var channelSkinBloc = Provider.of<ChannelsListSkinBloc>(context);
    return Container(
        decoration: BoxDecoration(
            color: channelSkinBloc
                .getChannelUnreadItemBackgroundColor(isChannelActive)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(unreadCount.toString(),
              style:
                  channelSkinBloc.getChannelUnreadTextStyle(isChannelActive)),
        ));
  } else {
    return Container();
  }
}

buildChannelUnreadCountBadge(BuildContext context,
    NetworkChannelBloc channelBloc, bool isChannelActive) {
  return StreamBuilder<int>(
    stream: channelBloc.networkChannelUnreadCountStream,
    initialData: channelBloc.networkChannelUnreadCount,
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
      var unreadCount = snapshot.data;

      if (unreadCount != null && unreadCount > 0) {
        return _buildChannelUnreadBadgeCount(
            context, isChannelActive, unreadCount);
      } else {
        return Container();
      }
    },
  );
}
