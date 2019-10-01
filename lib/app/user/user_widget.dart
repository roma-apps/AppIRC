import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_popup_menu_widget.dart';

Widget buildUserNickWithPopupMenu(BuildContext context, Text child, String nick,
    NetworkChannelBloc channelBloc,
    {Function(PlatformAwarePopupMenuAction action) actionCallback}) {
  return createPlatformPopupMenuButton(context,
      child: child,
      actions: <PlatformAwarePopupMenuAction>[
        PlatformAwarePopupMenuAction(
            text: "User information",
            iconData: Icons.account_box,
            actionCallback: (action) {
              channelBloc.printUserInfo(nick);
              if (actionCallback != null) {
                actionCallback(action);
              }
            }),
        PlatformAwarePopupMenuAction(
            text: "Direct Messages",
            iconData: Icons.message,
            actionCallback: (action) {
              channelBloc.openDirectMessagesChannel(nick);
              if (actionCallback != null) {
                actionCallback(action);
              }
            })
      ]);
}
