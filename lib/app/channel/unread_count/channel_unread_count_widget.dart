import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';

Widget _buildChannelUnreadBadgeCount(
  BuildContext context,
  bool isChannelActive,
  int unreadCount,
) {
  if (unreadCount > 0) {
    return Container(
      decoration: BoxDecoration(
        color: isChannelActive
            ? IAppIrcUiColorTheme.of(context).primary
            : IAppIrcUiColorTheme.of(context).primaryDark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          unreadCount.toString(),
          style: isChannelActive
              ? IAppIrcUiTextTheme.of(context).mediumDarkGrey
              : IAppIrcUiTextTheme.of(context).mediumWhite,
        ),
      ),
    );
  } else {
    return Container();
  }
}

StreamBuilder<int> buildChannelUnreadCountBadge(
    BuildContext context, ChannelBloc channelBloc, bool isChannelActive) {
  return StreamBuilder<int>(
    stream: channelBloc.channelUnreadCountStream,
    initialData: channelBloc.channelUnreadCount,
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
