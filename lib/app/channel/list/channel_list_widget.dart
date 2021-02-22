import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu.dart';
import 'package:flutter_appirc/app/channel/connection/channel_connection_widget.dart';
import 'package:flutter_appirc/app/channel/unread_count/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';

import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("channel_list_widget.dart");

class ChannelListWidget extends StatelessWidget {
  final Network network;

  final VoidCallback _onActionCallback;

  final bool _isChildInListView;

  ChannelListWidget(
    this.network,
    this._onActionCallback,
    this._isChildInListView,
  );

  @override
  Widget build(BuildContext context) {
    var networksListBloc = Provider.of<NetworkListBloc>(context);
    var channelsListBloc = networksListBloc.getChannelListBloc(network);

    if (channelsListBloc == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Channel>>(
      stream: channelsListBloc.channelsStream,
      initialData: channelsListBloc.channels,
      builder: (context, snapshot) {
        var channels = snapshot.data;

        _logger.fine(() => "channels $channels");
        var filteredChannels =
            channels.where((channel) => !channel.isLobby).toList();
        _logger.fine(() => "filteredChannels $filteredChannels");

        bool shrinkWrap;
        ClampingScrollPhysics scrollPhysics;
        if (_isChildInListView) {
          shrinkWrap = true;
          scrollPhysics = ClampingScrollPhysics();
        } else {
          shrinkWrap = false;
        }
        return ListView.builder(
          shrinkWrap: shrinkWrap,
          physics: scrollPhysics,
          itemCount: filteredChannels.length,
          itemBuilder: (BuildContext context, int index) => _channelItem(
            context,
            network,
            filteredChannels[index],
          ),
        );
      },
    );
  }

  Widget _channelItem(BuildContext context, Network network, Channel channel) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    return StreamBuilder<Channel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
        var activeChannel = snapshot.data;
        var isChannelActive = activeChannel?.remoteId == channel.remoteId;

        if (isChannelActive) {
          return Container(
            decoration: BoxDecoration(
              color: isChannelActive
                  ? IAppIrcUiColorTheme.of(context).lightGrey
                  : IAppIrcUiColorTheme.of(context).darkGrey,
            ),
            child: _buildChannelRow(
              context,
              network,
              channel,
              isChannelActive,
            ),
          );
        } else {
          return Container(
            child: _buildChannelRow(
              context,
              network,
              channel,
              isChannelActive,
            ),
          );
        }
      },
    );
  }

  Widget _buildChannelRow(
    BuildContext context,
    Network network,
    Channel channel,
    bool isChannelActive,
  ) {
    var networkBloc = NetworkBloc.of(context);

    var iconData = _calculateIconForChannelType(channel.type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ProxyProvider<ChannelBlocsBloc, ChannelBloc>(
        update: (context, channelBlocsBloc, _) =>
            channelBlocsBloc.getChannelBloc(channel),
        child: Builder(
          builder: (context) {
            var channelBloc = ChannelBloc.of(context);
            return StreamBuilder(
              initialData: channelBloc.channelConnected,
              stream: channelBloc.channelConnectedStream,
              builder: (context, snapshot) {
                bool channelConnected = snapshot.data;

                return Row(
                  children: <Widget>[
                    _buildChannelIconWidget(context, iconData, isChannelActive),
                    _buildChannelNameWidget(context, channel, isChannelActive),
                    _buildConnectionStateWidget(context, networkBloc,
                        isChannelActive, channelConnected),
                    buildChannelUnreadCountBadge(
                        context, channelBloc, isChannelActive),
                    buildChannelPopupMenuButton(
                      context: context,
                      networkBloc: networkBloc,
                      channelBloc: channelBloc,
                      iconColor: isChannelActive
                          ? IAppIrcUiColorTheme.of(context).primary
                          : IAppIrcUiColorTheme.of(context).darkGrey,
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  StreamBuilder<bool> _buildConnectionStateWidget(BuildContext context,
      NetworkBloc networkBloc, bool isChannelActive, bool channelConnected) {
    return StreamBuilder<bool>(
      stream: networkBloc.networkConnectedStream,
      initialData: networkBloc.networkConnected,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        var networkConnected = snapshot.data;

        return buildConnectionIcon(
          context,
          isChannelActive
              ? IAppIrcUiColorTheme.of(context).primary
              : IAppIrcUiColorTheme.of(context).white,
          networkConnected && channelConnected,
        );
      },
    );
  }

  Widget _buildChannelNameWidget(
      BuildContext context, Channel channel, bool isChannelActive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
        child: GestureDetector(
          onTap: () {
            if (_onActionCallback != null) {
              _onActionCallback();
            }
            var activeChannelBloc =
                Provider.of<ChatActiveChannelBloc>(context, listen: false);

            return activeChannelBloc.changeActiveChanel(channel);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              channel.name,
              style: isChannelActive
                  ? IAppIrcUiTextTheme.of(context).mediumBoldDarkGrey
                  : IAppIrcUiTextTheme.of(context).mediumBoldWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelIconWidget(
      BuildContext context, IconData iconData, bool isChannelActive) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
      child: Icon(
        iconData,
        color: isChannelActive
            ? IAppIrcUiColorTheme.of(context).primary
            : IAppIrcUiColorTheme.of(context).white,
      ),
    );
  }

  IconData _calculateIconForChannelType(ChannelType channelType) {
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
