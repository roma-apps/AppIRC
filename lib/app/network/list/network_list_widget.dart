import 'package:flutter/material.dart' show Divider, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/connection/channel_connection_widget.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_widget.dart';
import 'package:flutter_appirc/app/channel/unread_count/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_expand_state_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_popup_menu.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class NetworkListWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  NetworkListWidget(this.onActionCallback);

  @override
  Widget build(BuildContext context) {
    var networkListBloc = Provider.of<NetworkListBloc>(context);

    return StreamBuilder<List<Network>>(
      stream: networkListBloc.networksStream,
      initialData: networkListBloc.networks,
      builder: (BuildContext context, AsyncSnapshot<List<Network>> snapshot) {
        var networks = snapshot.data ?? [];

        if (networks.isNotEmpty) {
          return _buildNetworksListWidget(networks);
        } else {
          return _buildEmptyListWidget(context);
        }
      },
    );
  }

  Container _buildNetworksListWidget(List<Network> networks) {
    return Container(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: networks.length,
        separatorBuilder: (context, index) => Divider(
          color: IAppIrcUiColorTheme.of(context).grey,
        ),
        itemBuilder: (BuildContext context, int index) {
          var network = networks[index];
          return _networkItem(context, network);
        },
      ),
    );
  }

  Center _buildEmptyListWidget(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).chat_networks_list_empty,
        style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
      ),
    );
  }

  Widget _networkItem(BuildContext context, Network network) {
    var preferencesService = Provider.of<ILocalPreferencesService>(context);
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);
    var channel = network.lobbyChannel;
    var expandBloc = NetworkExpandStateBloc(preferencesService, network);

    var networkBloc = NetworkBlocsBloc.of(context).getNetworkBloc(network);
    return Provider<NetworkBloc>.value(
      value: networkBloc,
      child: StreamBuilder<bool>(
        stream: expandBloc.expandedStream,
        initialData: expandBloc.expanded,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          var expanded = snapshot.data;
          return StreamBuilder<Channel>(
            stream: activeChannelBloc.activeChannelStream,
            builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
              var activeChannel = snapshot.data;
              var isChannelActive = activeChannel?.remoteId == channel.remoteId;

              return _buildNetworkRow(
                context,
                network,
                isChannelActive,
                expanded,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNetworkRow(BuildContext context, Network network,
      bool isChannelActive, bool expanded) {
    var channel = network.lobbyChannel;
    var channelItemRow = _buildChannelItemWidget(
      context,
      network,
      channel,
      expanded,
      isChannelActive,
    );

    if (expanded == true) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          channelItemRow,
          ChannelListWidget(
            network,
            onActionCallback,
            true,
          )
        ],
      );
    } else {
      return channelItemRow;
    }
  }

  Widget _buildChannelItemWidget(
    BuildContext context,
    Network network,
    Channel channel,
    bool expanded,
    bool isChannelActive,
  ) {
    IconData networkExpandedStateIcon = _calculateExpandIconData(expanded);

    var networkBloc = NetworkBlocsBloc.of(context).getNetworkBloc(network);

    if (networkBloc == null) {
      return const SizedBox.shrink();
    }

    var channelBloc = ChannelBlocsBloc.of(context).getChannelBloc(channel);

    var row = Provider<ChannelBloc>.value(
      value: channelBloc,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildToggleExpandButton(
            context,
            networkBloc.network,
            networkExpandedStateIcon,
            isChannelActive,
            expanded,
          ),
          _buildNetworkTitle(
            context,
            networkBloc,
            isChannelActive,
          ),
          _buildConnectionIcon(
            context,
            networkBloc,
            isChannelActive,
          ),
          buildChannelUnreadCountBadge(
            context,
            channelBloc,
            isChannelActive,
          ),
          buildNetworkPopupMenuButton(
            context: context,
            networkBloc: networkBloc,
            iconColor: isChannelActive
                ? IAppIrcUiColorTheme.of(context).lightGrey
                : IAppIrcUiColorTheme.of(context).darkGrey,
          )
        ],
      ),
    );
    var rowContainer = Container(
      decoration: BoxDecoration(
        color: isChannelActive
            ? IAppIrcUiColorTheme.of(context).darkGrey
            : IAppIrcUiColorTheme.of(context).lightGrey,
      ),
      child: row,
    );
    return rowContainer;
  }

  StreamBuilder<bool> _buildConnectionIcon(
      BuildContext context, NetworkBloc networkBloc, bool isChannelActive) {
    return StreamBuilder(
      stream: networkBloc.networkConnectedStream,
      initialData: networkBloc.networkConnected,
      builder: (context, snapshot) {
        var connected = snapshot.data;
        return buildConnectionIcon(
          context,
          isChannelActive
              ? IAppIrcUiColorTheme.of(context).primary
              : IAppIrcUiColorTheme.of(context).darkGrey,
          connected,
        );
      },
    );
  }

  Expanded _buildNetworkTitle(
    BuildContext context,
    NetworkBloc networkBloc,
    bool isChannelActive,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (onActionCallback != null) {
            onActionCallback();
          }
          Channel channel = networkBloc.network.lobbyChannel;

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
                style: isChannelActive
                    ? IAppIrcUiTextTheme.of(context).mediumPrimary
                    : IAppIrcUiTextTheme.of(context).mediumDarkGrey,
              ),
            );
          },
        ),
      ),
    );
  }

  PlatformIconButton _buildToggleExpandButton(
    BuildContext context,
    Network network,
    IconData networkExpandedStateIcon,
    bool isChannelActive,
    bool expanded,
  ) {
    var preferencesService = ILocalPreferencesService.of(context);
    return PlatformIconButton(
      icon: Icon(
        networkExpandedStateIcon,
        color: isChannelActive
            ? IAppIrcUiColorTheme.of(context).primary
            : IAppIrcUiColorTheme.of(context).darkGrey,
      ),
      onPressed: () {
        var expandBloc = NetworkExpandStateBloc(preferencesService, network);
        if (expanded) {
          expandBloc.collapse();
        } else {
          expandBloc.expand();
        }
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
