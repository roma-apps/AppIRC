import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_join_channel_page.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_preferences_page.dart';
import 'package:flutter_appirc/app/widgets/menu_widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

PopupMenuButton<NetworkDropDownAction> buildNetworkPopupMenuButton(
  BuildContext context,
  NetworkBloc networkBloc,
  Color iconColor,
) {
  var network = networkBloc.network;
  var networkState = networkBloc.networkState;

  return PopupMenuButton<NetworkDropDownAction>(
    icon: Icon(
      Icons.more_vert,
      color: iconColor,
    ),
    onSelected: (value) async {
      _onDropdownSelected(value, context, network, networkBloc);
    },
    itemBuilder: (context) {
      return _buildDropdownItems(context, networkState.connected);
    },
  );
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
        text:
            appLocalizations.tr("settings.network_dropdown_menu.join_channel"),
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
        text: appLocalizations.tr("settings.network_dropdown_menu.disconnect"),
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
                  createDefaultNetworkPreferences(context))));
      break;
    case NetworkDropDownAction.JOIN_CHANNEL:
      Navigator.push(context,
          platformPageRoute(builder: (_) => NetworkChannelJoinPage(network)));
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

enum NetworkDropDownAction {
  EDIT,
  JOIN_CHANNEL,
  LIST_ALL_CHANNELS,
  LIST_IGNORED_USERS,
  CONNECT,
  DISCONNECT,
  EXIT
}
