import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_form_widget.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_popup_menu_widget.dart';
import 'package:flutter_appirc/app/user/users_list_page.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Widget buildChannelPopupMenuButton(BuildContext context,
    NetworkBloc networkBloc, NetworkChannelBloc channelBloc, Color iconColor) {
  var channel = channelBloc.channel;
  var network = networkBloc.network;

  if (channel.type == NetworkChannelType.LOBBY) {
    return buildNetworkPopupMenuButton(context, networkBloc, iconColor);
  }

  return createPlatformPopupMenuButton(context,
      child: Icon(Icons.more_vert, color: iconColor),
      actions: _buildMenuItems(context, network, channel));
}

List<PlatformAwarePopupMenuAction> _buildMenuItems(
    BuildContext context, Network network, NetworkChannel channel) {
  List<PlatformAwarePopupMenuAction> menuItems;

  NetworkChannelBloc channelBloc =
      Provider.of<ChatNetworkChannelsBlocsBloc>(context)
          .getNetworkChannelBloc(channel);

  switch (channel.type) {
    case NetworkChannelType.LOBBY:
      menuItems = [];
      break;
    case NetworkChannelType.SPECIAL:
      menuItems = [_buildCloseMenuItem(context, channelBloc)];
      break;
    case NetworkChannelType.QUERY:
      menuItems = _buildUserChannelMenuItems(context, channelBloc);
      break;
    case NetworkChannelType.CHANNEL:
      menuItems = _buildChannelMenuItems(context, channelBloc);
      break;
    case NetworkChannelType.UNKNOWN:
      menuItems = [];
      break;
  }

  return menuItems;
}

List<PlatformAwarePopupMenuAction> _buildChannelMenuItems(
    BuildContext context, NetworkChannelBloc channelBloc) {
  var items = <PlatformAwarePopupMenuAction>[
    _buildMembersMenuItem(context, channelBloc),
    _buildBannedUsersMenuItem(context, channelBloc),
    _buildCloseMenuItem(context, channelBloc),
  ];

  // TODO: report bug to lounge. Lounge have field "editTopic" in channel state
  //  but it is  false even if user can access to change topic for current channel
  //  if (channelBloc.networkChannelState.editTopicPossible == true) {
  //    items.insert(0, _buildEditTopicMenuItem(context, channelBloc));
  //  }
  items.insert(0, _buildEditTopicMenuItem(context, channelBloc));

  return items;
}

List<PlatformAwarePopupMenuAction> _buildUserChannelMenuItems(
    BuildContext context, NetworkChannelBloc channelBloc) {
  return <PlatformAwarePopupMenuAction>[
    _buildUserInformationMenuItem(context, channelBloc),
    _buildCloseMenuItem(context, channelBloc)
  ];
}

PlatformAwarePopupMenuAction _buildCloseMenuItem(
    BuildContext context, NetworkChannelBloc channelBloc) {
  var appLocalizations = AppLocalizations.of(context);
  return PlatformAwarePopupMenuAction(
      text: appLocalizations.tr("chat.channel.action.leave"),
      iconData: Icons.clear,
      actionCallback: (action) {
        channelBloc.leaveNetworkChannel();
      });
}

PlatformAwarePopupMenuAction _buildMembersMenuItem(
    BuildContext context, NetworkChannelBloc channelBloc) {
  var appLocalizations = AppLocalizations.of(context);
  return PlatformAwarePopupMenuAction(
      text: appLocalizations.tr("chat.channel.action.users"),
      iconData: Icons.group,
      actionCallback: (action) {
        Navigator.push(
            context,
            platformPageRoute(
                builder: (context) => NetworkChannelUsersPage(
                    channelBloc.network, channelBloc.channel)));
      });
}

PlatformAwarePopupMenuAction _buildUserInformationMenuItem(
    BuildContext context, NetworkChannelBloc channelBloc) {
  var appLocalizations = AppLocalizations.of(context);
  return PlatformAwarePopupMenuAction(
      text: appLocalizations
          .tr("chat.channel.action.user_information"),
      iconData: Icons.account_box,
      actionCallback: (action) {
        channelBloc.printUserInfo(channelBloc.channel.name);
      });
}

PlatformAwarePopupMenuAction _buildBannedUsersMenuItem(
    BuildContext context, NetworkChannelBloc channelBloc) {
  var appLocalizations = AppLocalizations.of(context);
  return PlatformAwarePopupMenuAction(
      text: appLocalizations.tr("chat.channel.action.list_banned"),
      iconData: Icons.list,
      actionCallback: (action) {
        channelBloc.printNetworkChannelBannedUsers();
      });
}

PlatformAwarePopupMenuAction _buildEditTopicMenuItem(
    BuildContext context, NetworkChannelBloc channelBloc) {
  var appLocalizations = AppLocalizations.of(context);
  return PlatformAwarePopupMenuAction(
      text: appLocalizations.tr("chat.channel.action.topic"),
      iconData: Icons.edit,
      actionCallback: (action) {
        showTopicDialog(context, channelBloc);
      });
}
