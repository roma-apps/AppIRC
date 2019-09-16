import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    show Colors, PopupMenuButton, PopupMenuEntry, Icons;
import 'package:flutter/src/material/popup_menu.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_chat_active_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_leave_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_list_banned_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_user_infromation_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_statistics_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_topic_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'menu_widgets.dart';

var _logger = MyLogger(logTag: "IRCNetworkChannelsListWidget", enabled: true);

class IRCNetworkChannelsListWidget extends StatelessWidget {
  final IRCNetwork network;

  IRCNetworkChannelsListWidget(this.network);

  @override
  Widget build(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);

    var channels = network.channelsWithoutLobby;
    return ListView.builder(
        shrinkWrap: true,
        itemCount: channels.length,
        itemBuilder: (BuildContext context, int index) {
          return _channelItem(context, lounge, network, channels[index]);
        });
  }

  Widget _channelItem(BuildContext context, LoungeService lounge,
      IRCNetwork network, IRCNetworkChannel channel) {
    var ircChatActiveChannelBloc =
        Provider.of<IRCChatActiveChannelBloc>(context);
    return StreamBuilder<IRCNetworkChannel>(
        stream: ircChatActiveChannelBloc.activeChannelStream,
        builder:
            (BuildContext context, AsyncSnapshot<IRCNetworkChannel> snapshot) {
          var activeChannel = snapshot.data;
          var isChannelActive = activeChannel?.remoteId == channel.remoteId;
          if (isChannelActive) {
            return Container(
                decoration: BoxDecoration(
                    color: UISkin.of(context).appSkin.accentColor),
                child: _buildChannelRow(context, ircChatActiveChannelBloc,
                    network, channel, lounge, isChannelActive));
          } else {
            return Container(
                child: _buildChannelRow(context, ircChatActiveChannelBloc,
                    network, channel, lounge, isChannelActive));
          }
        });
  }

  Widget _buildChannelRow(
      BuildContext context,
      IRCChatActiveChannelBloc ircChatActiveChannelBloc,
      IRCNetwork network,
      IRCNetworkChannel channel,
      LoungeService lounge,
      bool isChannelActive) {
    var iconData = Icons.message;

    switch (channel.type) {
      case IRCNetworkChannelType.LOBBY:
        iconData = Icons.message;
        break;
      case IRCNetworkChannelType.SPECIAL:
        iconData = Icons.list;
        break;
      case IRCNetworkChannelType.QUERY:
        iconData = Icons.account_circle;
        break;
      case IRCNetworkChannelType.CHANNEL:
        iconData = Icons.group;
        break;
      case IRCNetworkChannelType.UNKNOWN:
        iconData = Icons.message;
        break;
    }

    var foregroundColor = calculateForegroundColor(isChannelActive);

    return Row(children: <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
        child: Icon(iconData, color: foregroundColor),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () => ircChatActiveChannelBloc.changeActiveChanel(channel),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(8.0),
                      child: Text(channel.name,
                          style: UISkin.of(context)
                              .appSkin
                              .networksListChannelTextStyle.copyWith(color: foregroundColor)))
                ]),
          ),
        ),
      ),
      buildChannelUnreadCountBadge(lounge, channel),
      _buildPopupMenuButton(lounge, channel, context, foregroundColor)
    ]);
  }

  PopupMenuButton<ChannelDropDownAction> _buildPopupMenuButton(
      LoungeService lounge, IRCNetworkChannel channel, BuildContext context, Color foregroundColor) {
    return PopupMenuButton<ChannelDropDownAction>(
      icon: Icon(Icons.more_vert, color: foregroundColor),
      onSelected: (value) async {
        switch (value) {
          case ChannelDropDownAction.LEAVE:
            IRCNetworkChannelCommandLeaveBloc(lounge: lounge, channel: channel)
                .sendCloseIRCCommand(channelName: channel.name);
            break;
          case ChannelDropDownAction.TOPIC:
            showPlatformDialog(
                context: context,
                builder: (_) => IRCNetworkChannelTopicEditWidget(channel),
                androidBarrierDismissible: true);
            break;
          case ChannelDropDownAction.LIST_BANNED:
            IRCNetworkChannelCommandListBannedBloc(
                    lounge: lounge, channel: channel)
                .sendIRCBanListCommand();
            break;
          case ChannelDropDownAction.USER_INFORMATION:
            IRCNetworkChannelCommandUserInformationBloc(
                    // network name used as user name only in direct messages channels
                    lounge: lounge,
                    channel: channel,
                    username: network.name)
                .sendIRCUserInformationCommand();
            break;
        }
      },
      itemBuilder: (context) {
        return _buildMenuItems(context, channel);
      },
    );
  }

  List<PopupMenuEntry<ChannelDropDownAction>> _buildMenuItems(
      BuildContext context, IRCNetworkChannel channel) {
    List<PopupMenuEntry<ChannelDropDownAction>> menuItems;

    var appLocalizations = AppLocalizations.of(context);

    switch (channel.type) {
      case IRCNetworkChannelType.LOBBY:
        menuItems = [];
        break;
      case IRCNetworkChannelType.SPECIAL:
        menuItems = [_buildCloseMenuItem(context)];
        break;
      case IRCNetworkChannelType.QUERY:
        _buildUserChannelMenuItems(context);
        break;
      case IRCNetworkChannelType.CHANNEL:
        menuItems = _buildChannelMenuItems(context, channel);
        break;
      case IRCNetworkChannelType.UNKNOWN:
        menuItems = [];
        break;
    }

    if (channel.isEditTopicPossible == true) {
      menuItems.insert(
          0,
          buildDropdownMenuItemRow(
              value: ChannelDropDownAction.TOPIC,
              text: appLocalizations.tr("settings.channel_dropdown_menu.topic"),
              iconData: Icons.edit));
    }

    return menuItems;
  }

  List<PopupMenuEntry<ChannelDropDownAction>> _buildChannelMenuItems(
      BuildContext context, IRCNetworkChannel channel) {
    var appLocalizations = AppLocalizations.of(context);

    var items = <PopupMenuEntry<ChannelDropDownAction>>[
      buildDropdownMenuItemRow(
          value: ChannelDropDownAction.LIST_BANNED,
          text:
              appLocalizations.tr("settings.channel_dropdown_menu.list_banned"),
          iconData: Icons.list),
      buildDropdownMenuItemRow(
          value: ChannelDropDownAction.LEAVE,
          text: appLocalizations.tr("settings.channel_dropdown_menu.leave"),
          iconData: Icons.clear)
    ];

    return items;
  }

  List<PopupMenuEntry<ChannelDropDownAction>> _buildUserChannelMenuItems(
      BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    return <PopupMenuEntry<ChannelDropDownAction>>[
      buildDropdownMenuItemRow(
          value: ChannelDropDownAction.USER_INFORMATION,
          text: appLocalizations
              .tr("settings.channel_dropdown_menu.user_infromation"),
          iconData: Icons.edit),
      _buildCloseMenuItem(context)
    ];
  }

  PopupMenuItem<ChannelDropDownAction> _buildCloseMenuItem(
      BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return buildDropdownMenuItemRow(
        value: ChannelDropDownAction.LEAVE,
        text: appLocalizations.tr("settings.channel_dropdown_menu.close"),
        iconData: Icons.clear);
  }
}

enum ChannelDropDownAction { LEAVE, TOPIC, LIST_BANNED, USER_INFORMATION }

Color calculateForegroundColor(bool isChannelActive) => isChannelActive ? Colors.white : Colors.black;
