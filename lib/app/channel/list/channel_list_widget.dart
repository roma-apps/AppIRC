import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu.dart';
import 'package:flutter_appirc/app/channel/connection/channel_connection_widget.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_skin_bloc.dart';
import 'package:flutter_appirc/app/channel/unread_count/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

MyLogger _logger = MyLogger(logTag: "channel_list_widget.dart", enabled: true);

class ChannelListWidget extends StatelessWidget {
  final Network _network;

  final VoidCallback _onActionCallback;

  final bool _isChildInListView;

  ChannelListWidget(
      this._network, this._onActionCallback, this._isChildInListView);

  @override
  Widget build(BuildContext context) {
    var networksListBloc = Provider.of<NetworkListBloc>(context);
    var channelsListBloc =
        networksListBloc.getChannelListBloc(_network);

    if(channelsListBloc == null) {
      return SizedBox.shrink();
    }

    return StreamBuilder<List<Channel>>(
        stream: channelsListBloc.channelsStream,
        initialData: channelsListBloc.channels,
        builder: (context, snapshot) {
          var channels = snapshot.data;

          _logger.d(() => "channels $channels");
          var filteredChannels =
              channels.where((channel) => !channel.isLobby).toList();
          _logger.d(() => "filteredChannels $filteredChannels");

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
              itemBuilder: (BuildContext context, int index) {
                return _channelItem(context, _network, filteredChannels[index]);
              });
        });
  }

  Widget _channelItem(
      BuildContext context, Network network, Channel channel) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    return StreamBuilder<Channel>(
        stream: activeChannelBloc.activeChannelStream,
        builder:
            (BuildContext context, AsyncSnapshot<Channel> snapshot) {
          var activeChannel = snapshot.data;
          var isChannelActive = activeChannel?.remoteId == channel.remoteId;

          if (isChannelActive) {
            return Container(
                decoration: BoxDecoration(
                    color: Provider.of<ChannelListSkinBloc>(context)
                        .getChannelItemBackgroundColor(isChannelActive)),
                child: _buildChannelRow(
                    context, network, channel, isChannelActive));
          } else {
            return Container(
                child: _buildChannelRow(
                    context, network, channel, isChannelActive));
          }
        });
  }

  Widget _buildChannelRow(BuildContext context, Network network,
      Channel channel, bool isChannelActive) {
    var networkBloc = NetworkBloc.of(context);

    var iconData = _calculateIconForChannelType(channel.type);

    var channelBloc =
        ChannelBlocsBloc.of(context).getChannelBloc(channel);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Provider(
        providable: ChannelBlocProvider(channelBloc),
        child: StreamBuilder(
            initialData: channelBloc.channelConnected,
            stream: channelBloc.channelConnectedStream,
            builder: (context, snapshot) {
              bool channelConnected = snapshot.data;

              var channelsListSkinBloc =
                  Provider.of<ChannelListSkinBloc>(context);

              return Row(children: <Widget>[
                _buildChannelIconWidget(context, iconData, isChannelActive),
                _buildChannelNameWidget(context, channel, isChannelActive),
                _buildConnectionStateWidget(
                    context, networkBloc, isChannelActive, channelConnected),
                buildChannelUnreadCountBadge(
                    context, channelBloc, isChannelActive),
                buildChannelPopupMenuButton(
                    context: context,
                    networkBloc: networkBloc,
                    channelBloc: channelBloc,
                    iconColor: channelsListSkinBloc
                        .getChannelItemIconColor(isChannelActive))
              ]);
            }),
      ),
    );
  }

  StreamBuilder<bool> _buildConnectionStateWidget(BuildContext context,
      NetworkBloc networkBloc, bool isChannelActive, bool channelConnected) {
    var channelsListSkinBloc = Provider.of<ChannelListSkinBloc>(context);

    return StreamBuilder<bool>(
        stream: networkBloc.networkConnectedStream,
        initialData: networkBloc.networkConnected,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          var networkConnected = snapshot.data;

          return buildConnectionIcon(
              context,
              channelsListSkinBloc.getChannelItemIconColor(isChannelActive),
              networkConnected && channelConnected);
        });
  }

  Widget _buildChannelNameWidget(
      BuildContext context, Channel channel, bool isChannelActive) {
    var channelsListSkinBloc = Provider.of<ChannelListSkinBloc>(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
        child: GestureDetector(
          onTap: () {
            if (_onActionCallback != null) {
              _onActionCallback();
            }
            var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

            return activeChannelBloc.changeActiveChanel(channel);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(channel.name,
                style: channelsListSkinBloc
                    .getChannelItemTextStyle(isChannelActive)),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelIconWidget(
      BuildContext context, IconData iconData, bool isChannelActive) {
    var channelsListSkinBloc = Provider.of<ChannelListSkinBloc>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
      child: Icon(iconData,
          color: channelsListSkinBloc.getChannelItemIconColor(isChannelActive)),
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
