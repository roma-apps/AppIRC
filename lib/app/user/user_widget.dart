import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

Widget buildUserNickWithPopupMenu({
  @required BuildContext context,
  @required String nick,
  @required Function(PlatformAwarePopupMenuAction action) actionCallback,
}) {
  var nickNamesBloc = Provider.of<ColoredNicknamesBloc>(context);
  var messagesSkin = Provider.of<MessageSkinBloc>(context);

  Widget child = Text(
    nick,
    style:
        messagesSkin.createNickTextStyle(nickNamesBloc.getColorForNick(nick)),
  );

  return createPlatformPopupMenuButton(
    context,
    child: child,
    isNeedPadding: false,
    actions: buildUserNickPopupMenuActions(
      context: context,
      nick: nick,
      actionCallback: actionCallback,
    ),
  );
}

Future showPopupMenuForUser(
  BuildContext context,
  RelativeRect position,
  String nick,
  ChannelBloc channelBloc,
) =>
    showPlatformAwarePopup(
      context,
      position,
      buildUserNickPopupMenuActions(
        context: context,
        nick: nick,
        actionCallback: null,
      ),
    );

List<PlatformAwarePopupMenuAction> buildUserNickPopupMenuActions(
    {@required BuildContext context,
    @required String nick,
    @required actionCallback(PlatformAwarePopupMenuAction action)}) {
  ChannelBloc channelBloc = ChannelBloc.of(context);
  return <PlatformAwarePopupMenuAction>[
    PlatformAwarePopupMenuAction(
        text: tr("chat.user.action.information"),
        iconData: Icons.account_box,
        actionCallback: (action) {
          channelBloc.printUserInfo(nick);
          if (actionCallback != null) {
            actionCallback(action);
          }
        }),
    PlatformAwarePopupMenuAction(
        text: tr("chat.user.action"
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
