import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_connection_status_widget.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu_widget.dart';
import 'package:flutter_appirc/app/channel/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/channel/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkChannelsListWidget extends StatelessWidget {
  final Network network;

  final VoidCallback onActionCallback;

  NetworkChannelsListWidget(this.network, this.onActionCallback);

  @override
  Widget build(BuildContext context) {
    var networksListBloc = Provider.of<ChatNetworksListBloc>(context);
    var channelsListBloc =
        networksListBloc.getChatNetworkChannelsListBloc(network);

    return StreamBuilder<List<NetworkChannel>>(
        stream: channelsListBloc.networkChannelsStream,
        initialData: channelsListBloc.networkChannels,
        builder: (context, snapshot) {
          var channels = snapshot.data;

          channels = channels.where((channel) => !channel.isLobby).toList();

          return ListView.builder(
              shrinkWrap: true,
              itemCount: channels.length,
              itemBuilder: (BuildContext context, int index) {
                return _channelItem(context, network, channels[index]);
              });
        });
  }

  Widget _channelItem(
      BuildContext context, Network network, NetworkChannel channel) {
    var ircChatActiveChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    return StreamBuilder<NetworkChannel>(
        stream: ircChatActiveChannelBloc.activeChannelStream,
        builder:
            (BuildContext context, AsyncSnapshot<NetworkChannel> snapshot) {
          var activeChannel = snapshot.data;
          var isChannelActive = activeChannel?.remoteId == channel.remoteId;
          if (isChannelActive) {
            return Container(
                decoration: BoxDecoration(
                    color: Provider.of<ChannelsListSkinBloc>(context)
                        .getChannelItemBackgroundColor(isChannelActive)),
                child: _buildChannelRow(context, ircChatActiveChannelBloc,
                    network, channel, isChannelActive));
          } else {
            return Container(
                child: _buildChannelRow(context, ircChatActiveChannelBloc,
                    network, channel, isChannelActive));
          }
        });
  }

  Widget _buildChannelRow(
      BuildContext context,
      ChatActiveChannelBloc activeChannelBloc,
      Network network,
      NetworkChannel channel,
      bool isChannelActive) {
    var networkBloc = NetworkBloc.of(context);

    var iconData = Icons.message;

    switch (channel.type) {
      case NetworkChannelType.LOBBY:
        iconData = Icons.message;
        break;
      case NetworkChannelType.SPECIAL:
        iconData = Icons.list;
        break;
      case NetworkChannelType.QUERY:
        iconData = Icons.account_circle;
        break;
      case NetworkChannelType.CHANNEL:
        iconData = Icons.group;
        break;
      case NetworkChannelType.UNKNOWN:
        iconData = Icons.message;
        break;
    }

    var channelBloc =
        ChatNetworkChannelsBlocsBloc.of(context).getNetworkChannelBloc(channel);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Provider(
        providable: NetworkChannelBlocProvider(channelBloc),
        child: StreamBuilder(
            initialData: channelBloc.networkChannelConnected,
            stream: channelBloc.networkChannelConnectedStream,
            builder: (context, snapshot) {
              bool channelConnected = snapshot.data;

              var channelsListSkinBloc =
                  Provider.of<ChannelsListSkinBloc>(context);
              return Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                  child: Icon(iconData,
                      color: channelsListSkinBloc
                          .getChannelItemIconColor(isChannelActive)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                    child: GestureDetector(
                      onTap: () {
                        if (onActionCallback != null) {
                          onActionCallback();
                        }
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
                ),
                StreamBuilder<bool>(
                    stream: networkBloc.networkConnectedStream,
                    initialData: networkBloc.networkConnected,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      var networkConnected = snapshot.data;

                      return buildConnectionIcon(
                          context,
                          channelsListSkinBloc
                              .getChannelItemIconColor(isChannelActive),
                          networkConnected && channelConnected);
                    }),
                buildChannelUnreadCountBadge(
                    context, channelBloc, isChannelActive),
                buildChannelPopupMenuButton(
                    context,
                    networkBloc,
                    channelBloc,
                    channelsListSkinBloc
                        .getChannelItemIconColor(isChannelActive))
              ]);
            }),
      ),
    );
  }
}
