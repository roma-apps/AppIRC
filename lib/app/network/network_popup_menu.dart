import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/async/async_operation_helper.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_page.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_edit_preferences_page.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("network_popup_menu.dart");

class NetworkPopupMenuButtonWidget extends StatelessWidget {
  final Color iconColor;
  final bool isNeedPadding;

  const NetworkPopupMenuButtonWidget({
    @required this.iconColor,
    this.isNeedPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    var networkBloc = NetworkBloc.of(context);
    return StreamBuilder<bool>(
      stream: networkBloc.networkConnectedStream,
      initialData: networkBloc.networkConnected,
      builder: (context, snapshot) {
        var connected = snapshot.data ?? false;
        return createPlatformPopupMenuButton(
          context,
          isNeedPadding: isNeedPadding,
          child: Icon(
            Icons.more_vert,
            color: iconColor,
          ),
          actions: _buildDropdownItems(
            context: context,
            connected: connected,
            networkBloc: networkBloc,
          ),
        );
      },
    );
  }
}

List<PlatformAwarePopupMenuAction> _buildDropdownItems({
  @required BuildContext context,
  @required bool connected,
  @required NetworkBloc networkBloc,
}) {
  _logger.fine(() => "_buildDropdownItems $connected");

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
    actionCallback: (action) async {
      var dialogResult = await AsyncOperationHelper.performAsyncOperation(
        context: context,
        asyncCode: () => backendService.getNetworkInfo(
          uuid: networkBloc.network.remoteId,
        ),
      );

      var connectionPreferences = networkBloc.network.connectionPreferences;

      if (dialogResult.success) {
        var loungeNetwork = dialogResult.result;
        connectionPreferences = NetworkConnectionPreferences(
          serverPreferences: NetworkServerPreferences(
            name: loungeNetwork.name,
            serverHost: loungeNetwork.host,
            serverPort: loungeNetwork.port.toString(),
            useTls: loungeNetwork.tls,
            useOnlyTrustedCertificates: loungeNetwork.rejectUnauthorized,
          ),
          userPreferences: NetworkUserPreferences(
            nickname: loungeNetwork.nick,
            password: loungeNetwork.password,
            commands: null,
            realName: loungeNetwork.realname,
            username: loungeNetwork.username,
          ),
        );
      }

      var titleText = S.of(context).irc_connection_edit_title;
      var buttonText = S.of(context).irc_connection_edit_action_save;

      await Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (_) {
            return Provider<NetworkBloc>.value(
              value: networkBloc,
              child: EditNetworkPreferencesPage(
                startValues: NetworkPreferences(
                  connectionPreferences,
                  [],
                ),
                titleText: titleText,
                buttonText: buttonText,
                serverPreferencesEnabled:
                    !backendService.chatConfig.lockNetwork,
                serverPreferencesVisible:
                    backendService.chatConfig.displayNetwork,
              ),
            );
          },
        ),
      );
    },
  );
}
