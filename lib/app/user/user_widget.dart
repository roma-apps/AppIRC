import 'package:flutter/material.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/widgets/menu_widgets.dart';

Widget buildUserNickWithPopupMenu(BuildContext context, Text child, String nick,
    NetworkChannelBloc channelBloc,
    {Function(MessageNickMenuAction action) actionCallback}) {
  return PopupMenuButton<MessageNickMenuAction>(
      child: child,
      onSelected: (MessageNickMenuAction selectedAction) {
        switch (selectedAction) {
          case MessageNickMenuAction.WHO_IS:
            channelBloc.printUserInfo(nick);

            break;
          case MessageNickMenuAction.DIRECT_MESSAGES:
            channelBloc.openDirectMessagesChannel(nick);
            break;
        }
        if (actionCallback != null) {
          actionCallback(selectedAction);
        }
      },
      itemBuilder: (context) {
        return [
          buildDropdownMenuItemRow(
              text: "User information",
              iconData: Icons.account_box,
              value: MessageNickMenuAction.WHO_IS),
          buildDropdownMenuItemRow(
              text: "Direct Messages",
              iconData: Icons.message,
              value: MessageNickMenuAction.DIRECT_MESSAGES)
        ];
      });
}
