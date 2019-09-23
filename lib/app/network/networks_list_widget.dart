import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart'
    show Divider, Icons, PopupMenuButton, PopupMenuEntry;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/channel/channels_list_widget.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_expand_state_bloc.dart';
import 'package:flutter_appirc/app/network/network_join_channel_page.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_preferences_page.dart';
import 'package:flutter_appirc/app/network/networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/widgets/menu_widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworksListWidget extends StatelessWidget {
  IRCNetworksListWidget();

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
            return Text(
                AppLocalizations.of(context).tr("irc_connection.no_networks"));
          }
        });

    return networksListWidget;
  }

  Widget _networkItem(BuildContext context, Network network) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var ircChatActiveChannelBloc =
        Provider.of<IRCChatActiveChannelBloc>(context);
    var backendService = Provider.of<ChatInputBackendService>(context);
    var networksStatesBloc = Provider.of<ChatNetworksStateBloc>(context);
    var channel = network.lobbyChannel;
    var expandBloc = IRCChatNetworkExpandStateBloc(preferencesService, network);
    var networkStateBloc =
        NetworkBloc(backendService, network, networksStatesBloc);

    return Provider<NetworkBloc>(
      providable: networkStateBloc,
      child: StreamBuilder<bool>(
        stream: expandBloc.expandedStream,
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
      IRCChatActiveChannelBloc ircChatActiveChannelBloc,
      Network network,
      NetworkChannel channel,
      bool isChannelActive,
      bool expanded,
      IRCChatNetworkExpandStateBloc expandBloc) {
    var networkExpandedStateIcon;

    if (expanded == true) {
      networkExpandedStateIcon = Icons.arrow_drop_down;
    } else {
      networkExpandedStateIcon = Icons.arrow_right;
    }

    var networkBloc = Provider.of<NetworkBloc>(context);
    var channelBloc = NetworkChannelBloc(
        Provider.of<ChatInputOutputBackendService>(context),
        network,
        network.lobbyChannel,
        Provider.of<ChatNetworkChannelsStateBloc>(context));
    var networkListSkinBloc = Provider.of<NetworkListSkinBloc>(context);

    var row = Provider(
        providable: channelBloc,
        child: StreamBuilder<NetworkState>(
            stream: networkBloc.networkStateStream,
            initialData: networkBloc.networkState,
            builder:
                (BuildContext context, AsyncSnapshot<NetworkState> snapshot) {
              var state = snapshot.data;
              var connected = state.connected;


              return Row(
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
                        ircChatActiveChannelBloc.changeActiveChanel(channel);
                      },
                      child: Text(network.name,
                          style: networkListSkinBloc
                              .getNetworkItemTextStyle(isChannelActive)),
                    ),
                  ),
                  buildConnectionIcon(context, networkListSkinBloc
                      .getNetworkItemIconColor(isChannelActive), connected),
                  buildChannelUnreadCountBadge(context, isChannelActive),
                  PopupMenuButton<NetworkDropDownAction>(
                    icon: Icon(Icons.more_vert, color: networkListSkinBloc
                        .getNetworkItemIconColor(isChannelActive)),
                    onSelected: (value) async {
                      _onDropdownSelected(value, context, network, networkBloc);
                    },
                    itemBuilder: (context) {
                      return _buildDropdownItems(context, connected);
                    },
                  )
                ],
              );
            }));
    var rowContainer = Container(
          decoration: BoxDecoration(color: networkListSkinBloc
              .getNetworkItemBackgroundColor(isChannelActive)),
          child: row);

    if (expanded == true) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            rowContainer,
            IRCNetworkChannelsListWidget(network)
          ]);
    } else {
      return rowContainer;
    }
  }

  List<PopupMenuEntry<NetworkDropDownAction>> _buildDropdownItems(
      BuildContext context, bool connected) {
    var appLocalizations = AppLocalizations.of(context);
    var items = <PopupMenuEntry<NetworkDropDownAction>>[
      buildDropdownMenuItemRow(
          value: NetworkDropDownAction.EDIT,
          text: appLocalizations.tr("settings.network_dropdown_menu.edit"),
          iconData: Icons.edit),
      buildDropdownMenuItemRow(
          value: NetworkDropDownAction.JOIN_CHANNEL,
          text: appLocalizations
              .tr("settings.network_dropdown_menu.join_channel"),
          iconData: Icons.add),
      buildDropdownMenuItemRow(
          value: NetworkDropDownAction.LIST_ALL_CHANNELS,
          text: appLocalizations
              .tr("settings.network_dropdown_menu.list_all_channels"),
          iconData: Icons.list),
      buildDropdownMenuItemRow(
          value: NetworkDropDownAction.LIST_IGNORED_USERS,
          text: appLocalizations
              .tr("settings.network_dropdown_menu.list_ignored_users"),
          iconData: Icons.list),
      buildDropdownMenuItemRow(
          value: NetworkDropDownAction.EXIT,
          text: appLocalizations.tr("settings.network_dropdown_menu.exit"),
          iconData: Icons.clear),
    ];

    if (connected) {
      items.add(buildDropdownMenuItemRow(
          value: NetworkDropDownAction.DISCONNECT,
          text:
              appLocalizations.tr("settings.network_dropdown_menu.disconnect"),
          iconData: Icons.cloud_off));
    } else {
      items.add(buildDropdownMenuItemRow(
          value: NetworkDropDownAction.CONNECT,
          text: appLocalizations.tr("settings.network_dropdown_menu.connect"),
          iconData: Icons.cloud));
    }
    return items;
  }

  void _onDropdownSelected(NetworkDropDownAction value, BuildContext context,
      Network network, NetworkBloc networkBloc) {
    switch (value) {
      case NetworkDropDownAction.EDIT:
        Navigator.push(
            context,
            platformPageRoute(
                builder: (_) => EditChatNetworkPage(
                    createDefaultIRCNetworkPreferences(context))));
        break;
      case NetworkDropDownAction.JOIN_CHANNEL:
        Navigator.push(
            context,
            platformPageRoute(
                builder: (_) => IRCNetworkChannelJoinPage(network)));
        break;
      case NetworkDropDownAction.LIST_ALL_CHANNELS:
        networkBloc.printNetworkAvailableChannels();
        break;
      case NetworkDropDownAction.LIST_IGNORED_USERS:
        networkBloc.printNetworkIgnoredUsers();
        break;
      case NetworkDropDownAction.DISCONNECT:
        networkBloc.disableNetwork();
        break;

      case NetworkDropDownAction.CONNECT:
        networkBloc.enableNetwork();
        break;
      case NetworkDropDownAction.EXIT:
        networkBloc.leaveNetwork();
        break;
    }
  }
}

enum NetworkDropDownAction {
  EDIT,
  JOIN_CHANNEL,
  LIST_ALL_CHANNELS,
  LIST_IGNORED_USERS,
  CONNECT,
  DISCONNECT,
  EXIT
}
