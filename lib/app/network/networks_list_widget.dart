import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart' show Divider, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_connection_status_widget.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/channel/channels_list_widget.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_expand_state_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_popup_menu_widget.dart';
import 'package:flutter_appirc/app/network/networks_list_skin_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NetworksListWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  NetworksListWidget(this.onActionCallback);

  @override
  Widget build(BuildContext context) {
    var networksListBloc = Provider.of<ChatNetworksListBloc>(context);

    var networksListWidget = StreamBuilder<List<Network>>(
        stream: networksListBloc.networksStream,
        builder: (BuildContext context, AsyncSnapshot<List<Network>> snapshot) {
          var listItemCount =
              (snapshot.data == null ? 0 : snapshot.data.length);

          if (listItemCount > 0) {
            return Container(
              child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: listItemCount,
                  separatorBuilder: (context, index) => Divider(
                        color: Provider.of<NetworkListSkinBloc>(context)
                            .separatorColor,
                      ),
                  itemBuilder: (BuildContext context, int index) {
                    var network = snapshot.data[index];

                    return _networkItem(context, network);
                  }),
            );
          } else {
            return Center(
              child: Text(
                  AppLocalizations.of(context).tr("irc_connection.no_networks"),
                  style: TextStyle(
                      color: AppSkinBloc.of(context).appSkinTheme.textColor)),
            );
          }
        });

    return networksListWidget;
  }

  Widget _networkItem(BuildContext context, Network network) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var ircChatActiveChannelBloc = Provider.of<ChatActiveChannelBloc>(context);
    var channel = network.lobbyChannel;
    var expandBloc = ChatNetworkExpandStateBloc(preferencesService, network);

    var networkBloc = ChatNetworksBlocsBloc.of(context).getNetworkBloc(network);
    return Provider(
      providable: NetworkBlocProvider(networkBloc),
      child: StreamBuilder<bool>(
        stream: expandBloc.expandedStream,
        initialData: expandBloc.expanded,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          var expanded = snapshot.data;
          return StreamBuilder<NetworkChannel>(
              stream: ircChatActiveChannelBloc.activeChannelStream,
              builder: (BuildContext context,
                  AsyncSnapshot<NetworkChannel> snapshot) {
                var activeChannel = snapshot.data;
                var isChannelActive =
                    activeChannel?.remoteId == channel.remoteId;

                return _buildNetworkRow(context, ircChatActiveChannelBloc,
                    network, channel, isChannelActive, expanded, expandBloc);
              });
        },
      ),
    );
  }

  _buildNetworkRow(
      BuildContext context,
      ChatActiveChannelBloc ircChatActiveChannelBloc,
      Network network,
      NetworkChannel channel,
      bool isChannelActive,
      bool expanded,
      ChatNetworkExpandStateBloc expandBloc) {
    var networkExpandedStateIcon;

    if (expanded == true) {
      networkExpandedStateIcon = Icons.arrow_drop_down;
    } else {
      networkExpandedStateIcon = Icons.arrow_right;
    }

    var networkBloc = ChatNetworksBlocsBloc.of(context).getNetworkBloc(network);

    var channelBloc =
        ChatNetworkChannelsBlocsBloc.of(context).getNetworkChannelBloc(channel);

    var networkListSkinBloc = Provider.of<NetworkListSkinBloc>(context);

    var row = Provider(
        providable: NetworkChannelBlocProvider(channelBloc),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            PlatformIconButton(
              icon: Icon(networkExpandedStateIcon,
                  color: networkListSkinBloc
                      .getNetworkItemIconColor(isChannelActive)),
              onPressed: () {
                if (expanded) {
                  expandBloc.collapse();
                } else {
                  expandBloc.expand();
                }
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (onActionCallback != null) {
                    onActionCallback();
                  }

                  ircChatActiveChannelBloc.changeActiveChanel(channel);
                },
                child: StreamBuilder<NetworkTitle>(
                    stream: networkBloc.networkTitleStream,
                    initialData: networkBloc.networkTitle,
                    builder: (context, snapshot) {
                      var title = snapshot.data;

                      var networkTitle = "${title.name} (${title.nick})";
                      return Text(networkTitle,
                          style: networkListSkinBloc
                              .getNetworkItemTextStyle(isChannelActive));
                    }),
              ),
            ),
            StreamBuilder(
                stream: networkBloc.networkConnectedStream,
                initialData: networkBloc.networkConnected,
                builder: (context, snapshot) {
                  var connected = snapshot.data;
                  return buildConnectionIcon(
                      context,
                      networkListSkinBloc
                          .getNetworkItemIconColor(isChannelActive),
                      connected);
                }),
            buildChannelUnreadCountBadge(context, channelBloc, isChannelActive),
            buildNetworkPopupMenuButton(context, networkBloc,
                networkListSkinBloc.getNetworkItemIconColor(isChannelActive))
          ],
        ));
    var rowContainer = Container(
        decoration: BoxDecoration(
            color: networkListSkinBloc
                .getNetworkItemBackgroundColor(isChannelActive)),
        child: row);

    if (expanded == true) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            rowContainer,
            NetworkChannelsListWidget(network, onActionCallback)
          ]);
    } else {
      return rowContainer;
    }
  }
}
