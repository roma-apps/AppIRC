import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:provider/provider.dart';

class _ChannelUnreadCountBadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var unreadCount = Provider.of<int>(context);

    var channel = Provider.of<Channel>(context);

    var chatActiveChannelBloc = ChatActiveChannelBloc.of(context);
    if (unreadCount > 0) {
      return StreamBuilder<bool>(
        stream: chatActiveChannelBloc.isChannelActiveStream(channel),
        initialData: chatActiveChannelBloc.isChannelActive(channel),
        builder: (context, snapshot) {
          var isChannelActive = snapshot.data;
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
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  const _ChannelUnreadCountBadgeWidget();
}

class ChannelUnreadCountBadgeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = ChannelBloc.of(context);
    return StreamBuilder<int>(
      stream: channelBloc.channelUnreadCountStream,
      initialData: channelBloc.channelUnreadCount,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        var unreadCount = snapshot.data;

        if (unreadCount != null && unreadCount > 0) {
          return Provider.value(
            value: unreadCount,
            child: const _ChannelUnreadCountBadgeWidget(),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  const ChannelUnreadCountBadgeWidget();
}
