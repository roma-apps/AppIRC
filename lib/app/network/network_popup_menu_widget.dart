import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_page.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_page.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Widget buildNetworkPopupMenuButton(
  BuildContext context,
  NetworkBloc networkBloc,
  Color iconColor,
) {
  return createPlatformPopupMenuButton(context,
    child: Icon(
      Icons.more_vert,
      color: iconColor,
    ),
    actions: _buildDropdownItems(
        context, networkBloc.networkConnected, networkBloc),
  );
}

List<PlatformAwarePopupMenuAction> _buildDropdownItems(
    BuildContext context, bool connected, NetworkBloc networkBloc) {
  var appLocalizations = AppLocalizations.of(context);

  ChatBackendService backendService = Provider.of(context);

  var items = <PlatformAwarePopupMenuAction>[
    PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.network.action.edit"),
        iconData: Icons.edit,
        actionCallback: (action) {
          Navigator.push(
              context,
              platformPageRoute(
                  builder: (_) => Provider(
                        providable: NetworkBlocProvider(networkBloc),
                        child: EditChatNetworkPage(
                            context,
                            ChatNetworkPreferences(
                                networkBloc.network.connectionPreferences,
                                []),
                          !backendService.chatConfig.lockNetwork,
                          backendService.chatConfig.displayNetwork
                        ),
                      )));
        }),
    PlatformAwarePopupMenuAction(
        text:
            appLocalizations.tr("chat.network.action.join_channel"),
        iconData: Icons.add,
        actionCallback: (action) {
          Navigator.push(
              context,
              platformPageRoute(
                  builder: (_) => NetworkChannelJoinPage(networkBloc.network)));
        }),
    PlatformAwarePopupMenuAction(
        text: appLocalizations
            .tr("chat.network.action.list_all_channels"),
        iconData: Icons.list,
        actionCallback: (action) {
          networkBloc.printNetworkAvailableChannels();
        }),
    PlatformAwarePopupMenuAction(
        text: appLocalizations
            .tr("chat.network.action.list_ignored_users"),
        iconData: Icons.list,
        actionCallback: (action) {
          networkBloc.printNetworkIgnoredUsers();
        }),
  ];

  if (connected) {
    items.add(PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.network.action.disconnect"),
        iconData: Icons.cloud_off,
        actionCallback: (action) {
          networkBloc.disableNetwork();
        }));
  } else {
    items.add(PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.network.action.connect"),
        iconData: Icons.cloud,
        actionCallback: (action) {
          networkBloc.enableNetwork();
        }));
  }
  items.add(PlatformAwarePopupMenuAction(
      text: appLocalizations.tr("chat.network.action.exit"),
      iconData: Icons.clear,
      actionCallback: (action) {
        networkBloc.leaveNetwork();
      }));
  return items;
}
