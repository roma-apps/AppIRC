import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/connection/channel_connection_widget.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_widget.dart';
import 'package:flutter_appirc/app/channel/unread_count/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_expand_state_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_popup_menu.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class NetworkListItemWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  NetworkListItemWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var preferencesService = Provider.of<ILocalPreferencesService>(context);

    return ProxyProvider<Network, NetworkExpandStateBloc>(
      update: (context, network, _) =>
          NetworkExpandStateBloc(preferencesService, network),
      child: NetworkListItemBodyWidget(
        onActionCallback: onActionCallback,
      ),
    );
  }
}

class NetworkListItemBodyWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  const NetworkListItemBodyWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var networkExpandStateBloc = Provider.of<NetworkExpandStateBloc>(context);

    return StreamBuilder<bool>(
      stream: networkExpandStateBloc.expandedStream,
      initialData: networkExpandStateBloc.expanded,
      builder: (context, snapshot) {
        var expanded = snapshot.data;

        if (expanded == true) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NetworkListItemChannelWidget(onActionCallback: onActionCallback),
              ChannelListWidget(
                onActionCallback: onActionCallback,
                isChildInListView: true,
              )
            ],
          );
        } else {
          return NetworkListItemChannelWidget(
            onActionCallback: onActionCallback,
          );
        }
      },
    );
  }
}

class NetworkListItemConnectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var networkBloc = NetworkBloc.of(context);
    return StreamBuilder(
      stream: networkBloc.networkConnectedStream,
      initialData: networkBloc.networkConnected,
      builder: (context, snapshot) {
        var connected = snapshot.data;
        return ChannelConnectionIconWidget(
          foregroundColor: IAppIrcUiColorTheme.of(context).darkGrey,
          connected: connected,
        );
      },
    );
  }

  const NetworkListItemConnectionWidget();
}

class NetworkListItemToggleExpandWidget extends StatelessWidget {
  const NetworkListItemToggleExpandWidget();

  @override
  Widget build(BuildContext context) {
    var networkExpandStateBloc = Provider.of<NetworkExpandStateBloc>(context);
    return StreamBuilder<Object>(
      stream: networkExpandStateBloc.expandedStream,
      initialData: networkExpandStateBloc.expanded,
      builder: (context, snapshot) {
        var expanded = snapshot.data;
        return PlatformIconButton(
          icon: Icon(
            _calculateExpandIconData(expanded),
            color: IAppIrcUiColorTheme.of(context).darkGrey,
          ),
          onPressed: () {
            if (expanded) {
              networkExpandStateBloc.collapse();
            } else {
              networkExpandStateBloc.expand();
            }
          },
        );
      },
    );
  }

  IconData _calculateExpandIconData(bool expanded) {
    IconData networkExpandedStateIcon;
    if (expanded == true) {
      networkExpandedStateIcon = Icons.arrow_drop_down;
    } else {
      networkExpandedStateIcon = Icons.arrow_right;
    }
    return networkExpandedStateIcon;
  }
}

class NetworkListItemTitleWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  const NetworkListItemTitleWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    Channel channel = Provider.of<Channel>(context);
    var networkBloc = NetworkBloc.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (onActionCallback != null) {
            onActionCallback();
          }

          var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(
            context,
            listen: false,
          );

          await activeChannelBloc.changeActiveChanel(channel);
        },
        child: StreamBuilder<NetworkTitle>(
          stream: networkBloc.networkTitleStream,
          initialData: networkBloc.networkTitle,
          builder: (context, snapshot) {
            var title = snapshot.data;

            var networkTitle = "${title.name} (${title.nick})";
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                networkTitle,
                style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
              ),
            );
          },
        ),
      ),
    );
  }
}

class NetworkListItemChannelBodyWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  const NetworkListItemChannelBodyWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var activeChannelBloc = ChatActiveChannelBloc.of(context);
    var channel = Provider.of<Channel>(context);

    return StreamBuilder<bool>(
      stream: activeChannelBloc.isChannelActiveStream(channel),
      initialData: activeChannelBloc.isChannelActive(channel),
      builder: (context, snapshot) {
        var isChannelActive = snapshot.data;
        return Container(
          decoration: BoxDecoration(
            color: isChannelActive
                ? IAppIrcUiColorTheme.of(context).lightGrey
                : IAppIrcUiColorTheme.of(context).transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const NetworkListItemToggleExpandWidget(),
              NetworkListItemTitleWidget(onActionCallback: onActionCallback),
              const NetworkListItemConnectionWidget(),
              const ChannelUnreadCountBadgeWidget(),
              NetworkPopupMenuButtonWidget(
                iconColor: IAppIrcUiColorTheme.of(context).darkGrey,
              ),
            ],
          ),
        );
      },
    );
  }
}

class NetworkListItemChannelWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  const NetworkListItemChannelWidget({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var channelBlocsBloc = ChannelBlocsBloc.of(context);

    return ProxyProvider<Network, Channel>(
      update: (context, network, _) => network.lobbyChannel,
      child: ProxyProvider<Channel, ChannelBloc>(
        update: (context, channel, _) =>
            channelBlocsBloc.getChannelBloc(channel),
        child: NetworkListItemChannelBodyWidget(
          onActionCallback: onActionCallback,
        ),
      ),
    );
  }
}
