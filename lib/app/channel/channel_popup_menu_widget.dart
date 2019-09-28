import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    show Colors, Icons, PopupMenuButton, PopupMenuEntry, PopupMenuItem;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_topic_widget.dart';
import 'package:flutter_appirc/app/channel/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_popup_menu_widget.dart';
import 'package:flutter_appirc/app/widgets/menu_widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "buildChannelPopupMenuButton", enabled: true);

enum ChannelDropDownAction { LEAVE, TOPIC, LIST_BANNED, USER_INFORMATION }

PopupMenuButton buildChannelPopupMenuButton(
    BuildContext context,
    NetworkBloc networkBloc,
    NetworkChannelBloc channelBloc,
    Color iconColor) {

  var channel = channelBloc.channel;
  var channelState = channelBloc.networkChannelState;
  var network = networkBloc.network;


  if (channel.type == NetworkChannelType.LOBBY) {
    return buildNetworkPopupMenuButton(
        context, networkBloc, iconColor);
  }

  return PopupMenuButton<ChannelDropDownAction>(
    icon: Icon(Icons.more_vert,
        color: iconColor),
    onSelected: (value) async {
      switch (value) {
        case ChannelDropDownAction.LEAVE:
          channelBloc.leaveNetworkChannel();
          break;
        case ChannelDropDownAction.TOPIC:
          showPlatformDialog(
              context: context,
              builder: (_) => IRCNetworkChannelTopicEditWidget(channel),
              androidBarrierDismissible: true);
          break;
        case ChannelDropDownAction.LIST_BANNED:
          channelBloc.printNetworkChannelBannedUsers();
          break;
        case ChannelDropDownAction.USER_INFORMATION:
          channelBloc.printUserInfo(network.name);
          break;
      }
    },
    itemBuilder: (context) {
      return _buildMenuItems(context, network, channel, channelState);
    },
  );
}

List<PopupMenuEntry<ChannelDropDownAction>> _buildMenuItems(
    BuildContext context,
    Network network,
    NetworkChannel channel,
    NetworkChannelState channelState) {
  List<PopupMenuEntry<ChannelDropDownAction>> menuItems;

  var appLocalizations = AppLocalizations.of(context);

  switch (channel.type) {
    case NetworkChannelType.LOBBY:
      menuItems = [];
      break;
    case NetworkChannelType.SPECIAL:
      menuItems = [_buildCloseMenuItem(context)];
      break;
    case NetworkChannelType.QUERY:
      menuItems = _buildUserChannelMenuItems(context);
      break;
    case NetworkChannelType.CHANNEL:
      menuItems = _buildChannelMenuItems(context, channel);
      break;
    case NetworkChannelType.UNKNOWN:
      menuItems = [];
      break;
  }

  if (channelState.editTopicPossible == true) {
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
    BuildContext context, NetworkChannel channel) {
  var appLocalizations = AppLocalizations.of(context);

  var items = <PopupMenuEntry<ChannelDropDownAction>>[
    buildDropdownMenuItemRow(
        value: ChannelDropDownAction.LIST_BANNED,
        text: appLocalizations.tr("settings.channel_dropdown_menu.list_banned"),
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
            .tr("settings.channel_dropdown_menu.user_information"),
        iconData: Icons.account_box),
    _buildCloseMenuItem(context)
  ];
}

PopupMenuItem<ChannelDropDownAction> _buildCloseMenuItem(BuildContext context) {
  var appLocalizations = AppLocalizations.of(context);
  return buildDropdownMenuItemRow(
      value: ChannelDropDownAction.LEAVE,
      text: appLocalizations.tr("settings.channel_dropdown_menu.close"),
      iconData: Icons.clear);
}
