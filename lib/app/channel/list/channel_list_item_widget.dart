import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu.dart';
import 'package:flutter_appirc/app/channel/connection/channel_connection_widget.dart';
import 'package:flutter_appirc/app/channel/unread_count/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:provider/provider.dart';

class ChannelListItemWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  ChannelListItemWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var channelBlocsBloc = Provider.of<ChannelBlocsBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ProxyProvider<Channel, ChannelBloc>(
        update: (context, channel, _) {
          return channelBlocsBloc.getChannelBloc(channel);
        },
        child: ChannelListItemBodyWidget(
          onActionCallback: onActionCallback,
        ),
      ),
    );
  }
}

class ChannelListItemBodyWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  ChannelListItemBodyWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var channel = Provider.of<Channel>(context);

    var chatActiveChannelBloc = ChatActiveChannelBloc.of(context);

    return Row(
      children: <Widget>[
        const ChannelListItemIconWidget(),
        ChannelListItemNameWidget(
          onActionCallback: onActionCallback,
        ),
        const ChannelListItemConnectionStateWidget(),
        const ChannelUnreadCountBadgeWidget(),
        StreamBuilder<bool>(
          stream: chatActiveChannelBloc.isChannelActiveStream(channel),
          initialData: chatActiveChannelBloc.isChannelActive(channel),
          builder: (context, snapshot) {
            var isChannelActive = snapshot.data;
            return ChannelPopupMenuButtonWidget(
              iconColor: isChannelActive
                  ? IAppIrcUiColorTheme.of(context).darkGrey
                  : IAppIrcUiColorTheme.of(context).darkGrey,
            );
          },
        )
      ],
    );
  }
}

class ChannelListItemConnectionStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var networkBloc = NetworkBloc.of(context);
    var channelBloc = ChannelBloc.of(context);
    return StreamBuilder<bool>(
      stream: networkBloc.networkConnectedStream,
      initialData: networkBloc.networkConnected,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        var networkConnected = snapshot.data;

        return StreamBuilder(
          initialData: channelBloc.channelConnected,
          stream: channelBloc.channelConnectedStream,
          builder: (context, snapshot) {
            bool channelConnected = snapshot.data;
            return ChannelConnectionIconWidget(
              foregroundColor: IAppIrcUiColorTheme.of(context).darkGrey,
              connected: networkConnected && channelConnected,
            );
          },
        );
      },
    );
  }

  const ChannelListItemConnectionStateWidget();
}

class ChannelListItemNameWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  ChannelListItemNameWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var channel = Provider.of<Channel>(context);

    var chatActiveChannelBloc = ChatActiveChannelBloc.of(context);

    return StreamBuilder<bool>(
        stream: chatActiveChannelBloc.isChannelActiveStream(channel),
        initialData: chatActiveChannelBloc.isChannelActive(channel),
        builder: (context, snapshot) {
          var isChannelActive = snapshot.data;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
              child: GestureDetector(
                onTap: () {
                  if (onActionCallback != null) {
                    onActionCallback();
                  }

                  return chatActiveChannelBloc.changeActiveChanel(channel);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    channel.name,
                    style: isChannelActive
                        ? IAppIrcUiTextTheme.of(context).mediumBoldDarkGrey
                        : IAppIrcUiTextTheme.of(context).mediumBoldDarkGrey,
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class ChannelListItemIconWidget extends StatelessWidget {
  const ChannelListItemIconWidget();

  @override
  Widget build(BuildContext context) {
    var channel = Provider.of<Channel>(context);
    var iconData = _calculateIconForChannelType(channel.type);

    var chatActiveChannelBloc = ChatActiveChannelBloc.of(context);

    return StreamBuilder<bool>(
      stream: chatActiveChannelBloc.isChannelActiveStream(channel),
      initialData: chatActiveChannelBloc.isChannelActive(channel),
      builder: (context, snapshot) {
        var isChannelActive = snapshot.data;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
          child: Icon(
            iconData,
            color: isChannelActive
                ? IAppIrcUiColorTheme.of(context).darkGrey
                : IAppIrcUiColorTheme.of(context).darkGrey,
          ),
        );
      },
    );
  }

  static IconData _calculateIconForChannelType(ChannelType channelType) {
    var iconData = Icons.message;
    // default

    switch (channelType) {
      case ChannelType.lobby:
        iconData = Icons.message;
        break;
      case ChannelType.special:
        iconData = Icons.list;
        break;
      case ChannelType.query:
        iconData = Icons.account_circle;
        break;
      case ChannelType.channel:
        iconData = Icons.group;
        break;
      case ChannelType.unknown:
        iconData = Icons.message;
        break;
    }
    return iconData;
  }
}
