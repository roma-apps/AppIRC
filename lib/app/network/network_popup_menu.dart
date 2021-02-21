import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_page.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_edit_preferences_page.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

MyLogger _logger = MyLogger(logTag: "network_popup_menu.dart", enabled: true);

Widget buildNetworkPopupMenuButton({
  @required BuildContext context,
  @required NetworkBloc networkBloc,
  @required Color iconColor,
}) {
  return StreamBuilder<bool>(
      stream: networkBloc.networkConnectedStream,
      initialData: networkBloc.networkConnected,
      builder: (context, snapshot) {
        var connected = snapshot.data ?? false;
        return createPlatformPopupMenuButton(
          context,
          child: Icon(
            Icons.more_vert,
            color: iconColor,
          ),
          actions: _buildDropdownItems(
              context: context, connected: connected, networkBloc: networkBloc),
        );
      });
}

List<PlatformAwarePopupMenuAction> _buildDropdownItems(
    {@required BuildContext context,
    @required bool connected,
    @required NetworkBloc networkBloc}) {
  _logger.d(() => "_buildDropdownItems $connected");

  ChatBackendService backendService = Provider.of(context);

  var items = <PlatformAwarePopupMenuAction>[
    _buildEditAction(context, networkBloc, backendService),
    _buildJoinChannelAction(context, networkBloc),
    _buildChannelsListAction(context, networkBloc),
    _buildIgnoredUsersListAction(context, networkBloc),
  ];

  if (connected) {
    _buildDisconnectionAction(context, items, networkBloc);
  } else {
    _buildConnectAction(context, items, networkBloc);
  }
  _buildLeaveAction(context, items, networkBloc);
  return items;
}

void _buildLeaveAction(BuildContext context,
    List<PlatformAwarePopupMenuAction> items, NetworkBloc networkBloc) {
  return items.add(
    PlatformAwarePopupMenuAction(
      text: S.of(context).chat_network_action_exit,
      iconData: Icons.clear,
      actionCallback: (action) {
        networkBloc.leaveNetwork();
      },
    ),
  );
}

void _buildConnectAction(BuildContext context,
    List<PlatformAwarePopupMenuAction> items, NetworkBloc networkBloc) {
  return items.add(
    PlatformAwarePopupMenuAction(
      text: S.of(context).chat_network_action_connect,
      iconData: Icons.cloud,
      actionCallback: (action) {
        networkBloc.enableNetwork();
      },
    ),
  );
}

void _buildDisconnectionAction(BuildContext context,
    List<PlatformAwarePopupMenuAction> items, NetworkBloc networkBloc) {
  return items.add(
    PlatformAwarePopupMenuAction(
      text: S.of(context).chat_network_action_disconnect,
      iconData: Icons.cloud_off,
      actionCallback: (action) {
        networkBloc.disableNetwork();
      },
    ),
  );
}

PlatformAwarePopupMenuAction _buildIgnoredUsersListAction(
    BuildContext context, NetworkBloc networkBloc) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_network_action_list_ignored_users,
    iconData: Icons.list,
    actionCallback: (action) {
      networkBloc.printNetworkIgnoredUsers();
    },
  );
}

PlatformAwarePopupMenuAction _buildChannelsListAction(
    BuildContext context, NetworkBloc networkBloc) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_network_action_list_all_channels,
    iconData: Icons.list,
    actionCallback: (action) {
      networkBloc.printNetworkAvailableChannels();
    },
  );
}

PlatformAwarePopupMenuAction _buildJoinChannelAction(
    BuildContext context, NetworkBloc networkBloc) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_network_action_join_channel,
    iconData: Icons.add,
    actionCallback: (action) {
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => NetworkJoinChannelPage(networkBloc.network),
        ),
      );
    },
  );
}

PlatformAwarePopupMenuAction _buildEditAction(
  BuildContext context,
  NetworkBloc networkBloc,
  ChatBackendService backendService,
) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_network_action_edit,
    iconData: Icons.edit,
    actionCallback: (action) {
      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (_) => Provider<NetworkBloc>.value(
            value: networkBloc,
            child: EditNetworkPreferencesPage(
              context: context,
              startValues: NetworkPreferences(
                networkBloc.network.connectionPreferences,
                [],
              ),
              serverPreferencesEnabled: !backendService.chatConfig.lockNetwork,
              serverPreferencesVisible:
                  backendService.chatConfig.displayNetwork,
            ),
          ),
        ),
      );
    },
  );
}
