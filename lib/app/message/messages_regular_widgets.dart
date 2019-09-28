import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/messages_colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/widgets/menu_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

var todayDateFormatter = new DateFormat().add_Hm();
var regularDateFormatter = new DateFormat().add_yMd().add_Hm();

class NetworkChannelMessageWidget extends StatelessWidget {
  final RegularMessage message;

  NetworkChannelMessageWidget(this.message);

  @override
  Widget build(BuildContext context) {
    var needHighlight = isNeedHighlight(message);

    var channelBloc = Provider.of<NetworkChannelBloc>(context);

    var body = _buildMessageBody(context);
    var title = _buildMessageTitle(context, channelBloc);
    return buildRegularMessage(title, body, needHighlight);
  }

  Widget _buildMessageBody(BuildContext context) {
    var regularMessageType = message.regularMessageType;

    if (regularMessageType == RegularMessageType.AWAY ||
        regularMessageType == RegularMessageType.JOIN ||
        regularMessageType == RegularMessageType.TOPIC_SET_BY ||
        regularMessageType == RegularMessageType.MOTD ||
        regularMessageType == RegularMessageType.MODE_CHANNEL ||
        regularMessageType == RegularMessageType.BACK) {
      return Container();
    }
    if (regularMessageType == RegularMessageType.MODE) {
      if (!isHaveLongText(message)) {
        return Container();
      }
    }

    var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

    var rows = <Widget>[
//      Text("${message.type}"),
    ];

    var params = message.params;

    if (params != null) {
      rows.add(Text("${params.join(", ")}",
          style: messagesSkin.regularMessageBodyTextStyle));
    }

    if (message.text != null) {
      var text = message.text;

      rows.add(Linkify(
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        text: text,
        style: messagesSkin.regularMessageBodyTextStyle,
        linkStyle: messagesSkin
            .modifyToLinkTextStyle(messagesSkin.regularMessageBodyTextStyle),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildMessageTitle(
      BuildContext context, NetworkChannelBloc channelBloc) {
    var icon = _buildTitleIcon(context, message);

    var startPart;

    var subMessage = _buildTitleSubMessage(context);

    if (message.isHaveFromNick) {
      var messageTitleNick = _buildMessageTitleNick(context, channelBloc);
      if (subMessage != null) {
        startPart = Row(children: <Widget>[
          messageTitleNick,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: subMessage,
          )
        ]);
      } else {
        startPart = messageTitleNick;
      }
    } else {
      if (subMessage != null) {
        startPart = subMessage;
      }
    }

    var endPart;
    var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);
    var color =
        messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

    if (icon != null) {
      endPart = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildMessageTitleDate(context, message, color),
          icon,
        ],
      );
    } else {
      endPart = buildMessageTitleDate(context, message, color);
    }

    return buildMessageTitle(startPart, endPart);
  }

  Widget _buildMessageTitleNick(
      BuildContext context, NetworkChannelBloc channelBloc) {
    var nick = message.fromNick;
    return buildMessagesTitleNick(context, nick, channelBloc);
  }

  _buildTitleIcon(BuildContext context, RegularMessage message) {
    var iconData = _findTitleIconDataForMessage(message);
    var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

    var color =
        messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

    return buildMessageIcon(iconData, color);
  }


  Widget _buildTitleSubMessage(BuildContext context) {
    var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

    var regularMessageType = message.regularMessageType;
    var appLocalizations = AppLocalizations.of(context);
    String str;
    switch (regularMessageType) {
      case RegularMessageType.TOPIC_SET_BY:
        str = appLocalizations.tr("chat.sub_message.topic_set_by");
        break;
      case RegularMessageType.TOPIC:
        str = appLocalizations.tr("chat.sub_message.topic");
        break;
      case RegularMessageType.WHO_IS:
        str = appLocalizations.tr("chat.sub_message.who_is");
        break;
      case RegularMessageType.UNHANDLED:
        str = null;
        break;
      case RegularMessageType.UNKNOWN:
        str = appLocalizations.tr("chat.sub_message.unknown");
        break;
      case RegularMessageType.MESSAGE:
        str = null;
        break;
      case RegularMessageType.JOIN:
        str = appLocalizations.tr("chat.sub_message.join");
        break;
      case RegularMessageType.MODE:
        if (isHaveLongText(message)) {
          str = appLocalizations.tr("chat.sub_message.mode_long");
        } else {
          str = appLocalizations
              .tr("chat.sub_message.mode_short", args: [message.text]);
        }

        break;
      case RegularMessageType.MOTD:
        str =
            appLocalizations.tr("chat.sub_message.motd", args: [message.text]);
        break;
      case RegularMessageType.NOTICE:
        str = appLocalizations.tr("chat.sub_message.notice");
        break;
      case RegularMessageType.ERROR:
        str = appLocalizations.tr("chat.sub_message.error");
        break;
      case RegularMessageType.AWAY:
        str = appLocalizations.tr("chat.sub_message.away");
        break;
      case RegularMessageType.BACK:
        str = appLocalizations.tr("chat.sub_message.back");
        break;
      case RegularMessageType.MODE_CHANNEL:
        str = appLocalizations
            .tr("chat.sub_message.channel_mode", args: [message.text]);
        break;
      case RegularMessageType.QUIT:
        str = appLocalizations.tr("chat.sub_message.quit");
        break;
      case RegularMessageType.RAW:
        str = null;
        break;
      case RegularMessageType.PART:
        str = appLocalizations.tr("chat.sub_message.part");
        break;
      case RegularMessageType.NICK:
        str = appLocalizations
            .tr("chat.sub_message.nick", args: [message.newNick]);
        break;
    }

    if (str != null) {
      var color = messagesSkin.findTitleColorDataForMessage(regularMessageType);
      return Text(str, style: messagesSkin.createDateTextStyle(color));
    } else {
      return null;
    }
  }
}

isNeedHighlight(RegularMessage message) =>
    message.regularMessageType ==
    RegularMessageType.UNKNOWN; // TODO: remove debug UNKNOWN

bool isHaveLongText(RegularMessage message) =>
    message.text != null ? message.text.length > 10 : false;

IconData _findTitleIconDataForMessage(RegularMessage message) {
  IconData icon;
  switch (message.regularMessageType) {
    case RegularMessageType.TOPIC_SET_BY:
      icon = Icons.assistant_photo;
      break;
    case RegularMessageType.TOPIC:
      icon = Icons.title;
      break;
    case RegularMessageType.WHO_IS:
      icon = Icons.account_circle;
      break;
    case RegularMessageType.UNHANDLED:
      icon = Icons.info;
      break;
    case RegularMessageType.UNKNOWN:
      icon = Icons.help;
      break;
    case RegularMessageType.MESSAGE:
      icon = Icons.message;
      break;
    case RegularMessageType.JOIN:
      icon = Icons.arrow_forward;
      break;

    case RegularMessageType.AWAY:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.MODE:
      icon = Icons.info;
      break;
    case RegularMessageType.MOTD:
      icon = Icons.info;
      break;
    case RegularMessageType.NOTICE:
      icon = Icons.info;
      break;
    case RegularMessageType.ERROR:
      icon = Icons.error;
      break;
    case RegularMessageType.BACK:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.MODE_CHANNEL:
      icon = Icons.info;
      break;
    case RegularMessageType.QUIT:
      icon = Icons.exit_to_app;
      break;
    case RegularMessageType.RAW:
      icon = Icons.info;
      break;
    case RegularMessageType.PART:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.NICK:
      icon = Icons.accessibility_new;
      break;
  }
  return icon;
}

enum MessageNickMenuAction { WHO_IS, DIRECT_MESSAGES }

Widget buildRegularMessage(Widget title, Widget body, bool needHighlight) {
  var decoration;
  if (needHighlight) {
    decoration = BoxDecoration(border: Border.all(color: Colors.redAccent));
  }

  return Container(
    decoration: decoration,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: title,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: body,
          ),
        ],
      ),
    ),
  );
}

Widget buildMessageTitle(startPart, endPart) {
  if (startPart != null && endPart != null) {
    return Row(
        children: <Widget>[startPart, endPart],
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  } else {
    if (startPart != null) {
      return Align(child: startPart, alignment: Alignment.centerLeft);
    } else if (endPart != null) {
      return Align(child: endPart, alignment: Alignment.centerRight);
    } else {
      return Container();
    }
  }
}

Widget buildMessageTitleDate(
    BuildContext context, ChatMessage message, Color color) {
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  var dateString;

  var date = message.date;

  if (message.isMessageDateToday) {
    dateString = todayDateFormatter.format(date);
  } else {
    dateString = regularDateFormatter.format(date);
  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Text(
      dateString,
      style: messagesSkin.createDateTextStyle(color),
    ),
  );
}

PopupMenuButton<MessageNickMenuAction> buildMessagesTitleNick(
    BuildContext context, String nick, NetworkChannelBloc channelBloc) {
  var nickNamesBloc = Provider.of<MessagesColoredNicknamesBloc>(context);
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);

  return PopupMenuButton<MessageNickMenuAction>(
      child: Text(
        nick,
        style: messagesSkin
            .createNickTextStyle(nickNamesBloc.getColorForNick(nick)),
      ),
      onSelected: (MessageNickMenuAction selectedAction) {
        switch (selectedAction) {
          case MessageNickMenuAction.WHO_IS:
            channelBloc.printUserInfo(nick);
            break;
          case MessageNickMenuAction.DIRECT_MESSAGES:
            channelBloc.openDirectMessagesChannel(nick);
            break;
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


Icon buildMessageIcon(IconData iconData, Color color) {
  return Icon(iconData, color: color);
}