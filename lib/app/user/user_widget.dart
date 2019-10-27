import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';

Widget buildUserNickWithPopupMenu(BuildContext context, Widget child,
    String nick, NetworkChannelBloc channelBloc,
    {Function(PlatformAwarePopupMenuAction action) actionCallback}) {
  return createPlatformPopupMenuButton(context,
      child: child,
      actions:
          buildUserNickPopupMenuActions(context, channelBloc, nick,
              actionCallback));
}

showPopupMenuForUser(BuildContext context, RelativeRect position, String nick,
        NetworkChannelBloc channelBloc) =>
    showPlatformAwarePopup(
        context, position, buildUserNickPopupMenuActions(context, channelBloc,
        nick,
        null));

List<PlatformAwarePopupMenuAction> buildUserNickPopupMenuActions(
    BuildContext context,
    NetworkChannelBloc channelBloc,
    String nick,
    actionCallback(PlatformAwarePopupMenuAction action)) {
  var appLocalizations = AppLocalizations.of(context);
  return <PlatformAwarePopupMenuAction>[
    PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.user.action.information"),
        iconData: Icons.account_box,
        actionCallback: (action) {
          channelBloc.printUserInfo(nick);
          if (actionCallback != null) {
            actionCallback(action);
          }
        }),
    PlatformAwarePopupMenuAction(
        text: appLocalizations.tr("chat.user.action"
            ".direct_messages"),
        iconData: Icons.message,
        actionCallback: (action) {
          channelBloc.openDirectMessagesChannel(nick);
          if (actionCallback != null) {
            actionCallback(action);
          }
        })
  ];
}
