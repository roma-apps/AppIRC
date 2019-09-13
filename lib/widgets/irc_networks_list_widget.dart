import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart'
    show Colors, Divider, Icons, PopupMenuButton, PopupMenuEntry;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_chat_active_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_command_channels_list_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_command_connect_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_command_disconnect_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_command_exit_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_command_ignore_list_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/pages/irc_network_channel_join_page.dart';
import 'package:flutter_appirc/pages/irc_network_edit_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_statistics_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channels_list_widget.dart';
import 'package:flutter_appirc/widgets/menu_widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "IRCNetworksListWidget", enabled: true);

class IRCNetworksListWidget extends StatelessWidget {
  IRCNetworksListWidget();

  @override
  Widget build(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);
    var networksPreferencesBloc = Provider.of<IRCNetworksPreferencesBloc>(context);
    var networksListBloc = Provider.of<IRCNetworksListBloc>(context);

    var networksListWidget = StreamBuilder<List<IRCNetwork>>(
        stream: networksListBloc.newNetworksStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<IRCNetwork>> snapshot) {
          var listItemCount =
              (snapshot.data == null ? 0 : snapshot.data.length);

          return Container(
            child: ListView.separated(
                shrinkWrap: true,
                itemCount: listItemCount,
                separatorBuilder: (context, index) => Divider(
                      color: UISkin.of(context).appSkin.accentColor,
                    ),
                itemBuilder: (BuildContext context, int index) {
                  return _networkItem(context, snapshot.data[index]);
                }),
          );
        });

    return networksListWidget;
  }

  Widget _networkItem(BuildContext context, IRCNetwork network) {
    var ircChatActiveChannelBloc =
        Provider.of<IRCChatActiveChannelBloc>(context);
    var lounge = Provider.of<LoungeService>(context);
    var channel = network.lobbyChannel;

    return StreamBuilder<IRCNetworkChannel>(
        stream: ircChatActiveChannelBloc.activeChannelStream,
        builder:
            (BuildContext context, AsyncSnapshot<IRCNetworkChannel> snapshot) {
          var activeChannel = snapshot.data;
          var isChannelActive = activeChannel?.remoteId == channel.remoteId;

          return _buildNetworkRow(context, ircChatActiveChannelBloc, network,
              channel, lounge, isChannelActive);
        });
  }

  _buildNetworkRow(
      BuildContext context,
      IRCChatActiveChannelBloc ircChatActiveChannelBloc,
      IRCNetwork network,
      IRCNetworkChannel channel,
      lounge,
      bool isChannelActive) {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PlatformIconButton(
          androidIcon: Icon(Icons.arrow_right),
          iosIcon: Icon(Icons.arrow_right),
          onPressed: () {},
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              ircChatActiveChannelBloc.changeActiveChanel(channel);
            },
            child: Text(network.name,
                style: UISkin.of(context).appSkin.networksListNetworkTextStyle),
          ),
        ),
        buildChannelUnreadCountBadge(lounge, channel),
        PopupMenuButton<NetworkDropDownAction>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) async {
            switch (value) {
              case NetworkDropDownAction.EDIT:
                Navigator.push(
                    context,
                    platformPageRoute(
                        builder: (_) => IRCNetworkEditPage(network)));
                break;
              case NetworkDropDownAction.JOIN_CHANNEL:
                Navigator.push(
                    context,
                    platformPageRoute(
                        builder: (_) => IRCNetworkChannelJoinPage(network)));
                break;
              case NetworkDropDownAction.LIST_ALL_CHANNELS:
                IRCNetworkChannelCommandChannelsListBloc(lounge, network)
                    .sendListIRCCommand();
                break;
              case NetworkDropDownAction.LIST_IGNORED_USERS:
                IRCNetworkChannelCommandIgnoreListBloc(lounge, network)
                    .sendIgnoreListIRCCommand();
                break;
              case NetworkDropDownAction.DISCONNECT:
                IRCNetworkChannelCommandDisconnectBloc(lounge, network)
                    .sendDisconnectIRCCommand();
                break;

              case NetworkDropDownAction.CONNECT:
                IRCNetworkChannelCommandConnectBloc(lounge, network)
                    .sendConnectIRCCommand();
                break;
              case NetworkDropDownAction.EXIT:
                IRCNetworkChannelCommandExitBloc(lounge, network)
                    .sendExitIRCCommand();
                break;
            }
          },
          itemBuilder: (context) {
            var appLocalizations = AppLocalizations.of(context);
            var items = <PopupMenuEntry<NetworkDropDownAction>>[
              buildDropdownMenuItemRow(
                  value: NetworkDropDownAction.EDIT,
                  text: appLocalizations
                      .tr("settings.network_dropdown_menu.edit"),
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
                  text: appLocalizations
                      .tr("settings.network_dropdown_menu.exit"),
                  iconData: Icons.clear),
            ];

            if (network.status.connected) {
              items.add(buildDropdownMenuItemRow(
                  value: NetworkDropDownAction.DISCONNECT,
                  text: appLocalizations
                      .tr("settings.network_dropdown_menu.disconnect"),
                  iconData: Icons.cloud_off));
            } else {
              items.add(buildDropdownMenuItemRow(
                  value: NetworkDropDownAction.CONNECT,
                  text: appLocalizations
                      .tr("settings.network_dropdown_menu.connect"),
                  iconData: Icons.cloud));
            }
            return items;
          },
        )
      ],
    );
    var rowContainer;
    if (isChannelActive) {
      rowContainer = Container(
          decoration:
              BoxDecoration(color: UISkin.of(context).appSkin.accentColor),
          child: row);
    } else {
      rowContainer = Container(child: row);
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          rowContainer,
          IRCNetworkChannelsListWidget(network)
        ]);
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
