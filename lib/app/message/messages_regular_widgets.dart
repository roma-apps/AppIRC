import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

var todayDateFormatter = new DateFormat().add_Hm();
var oldDateFormatter = new DateFormat().add_yMd().add_Hm();

class IRCNetworkChannelMessageWidget extends StatelessWidget {
  final RegularMessage message;

  IRCNetworkChannelMessageWidget(this.message);

  @override
  Widget build(BuildContext context) {
    var uiSkin = UISkin.of(context);

    var decoration;

    if (isNeedHighlight(message)) {
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
              child: _buildMessageTitle(context, uiSkin),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: _buildMessageBody(context, uiSkin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBody(BuildContext context, UISkin uiSkin) {
    var regularMessageType = RegularMessage.regularMessageType(message);


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


    var rows = <Widget>[
//      Text("${message.type}"),
    ];

    var params = RegularMessage.params(message);

    if (params != null) {
      rows.add(Text("${params.join(", ")}",
          style: uiSkin.appSkin.channelMessagesBodyTextStyle));
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
        style: uiSkin.appSkin.channelMessagesBodyTextStyle,
        linkStyle: uiSkin.appSkin.channelMessagesBodyTextStyle
            .copyWith(color: Colors.blue),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildMessageTitle(BuildContext context, UISkin uiSkin) {
    var icon = _buildTitleIcon(message);

    var startPart;

    var subMessage = _buildTitleSubMessage(context, uiSkin);

    if (RegularMessage.isHaveFromNick(message)) {
      var messageTitleNick = _buildMessageTitleNick(uiSkin);
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

    if (icon != null) {
      endPart = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildMessageTitleDate(uiSkin),
          icon,
        ],
      );
    } else {
      endPart = _buildMessageTitleDate(uiSkin);
    }

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

  Padding _buildMessageTitleDate(UISkin uiSkin) {
    var dateString;

    var date = RegularMessage.date(message);

    if (RegularMessage.isMessageDateToday(message)) {
      dateString = todayDateFormatter.format(date);
    } else {
      dateString = oldDateFormatter.format(date);
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        dateString,
        style: uiSkin.appSkin.channelMessagesDateTextStyle
            .copyWith(color: _findTitleColorDataForMessage(message)),
      ),
    );
  }

  Text _buildMessageTitleNick(UISkin uiSkin) {
    return Text(
      message.fromNick,
      style: uiSkin.appSkin.channelMessagesNickTextStyle,
    );
  }

  _buildTitleIcon(RegularMessage message) {
    var iconData = _findTitleIconDataForMessage(message);
    var color = _findTitleColorDataForMessage(message);

    return Icon(iconData, color: color);
  }

  Widget _buildTitleSubMessage(BuildContext context, UISkin uiSkin) {

    var regularMessageType = RegularMessage.regularMessageType(message);
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
        str = appLocalizations.tr("chat.sub_message.nick");
        break;
    }

    if (str != null) {
      return Text(str,
          style: uiSkin.appSkin.channelMessagesDateTextStyle
              .copyWith(color: _findTitleColorDataForMessage(message)));
    } else {
      return null;
    }
  }
}

isNeedHighlight(RegularMessage message) =>
    message.highlight == true ||
RegularMessage.regularMessageType(message) ==
        RegularMessageType.UNKNOWN; // TODO: remove debug UNKNOWN

Color _findTitleColorDataForMessage(RegularMessage message) {
  var regularMessageType = RegularMessage.regularMessageType(message);
  Color color;
  switch (regularMessageType) {
    case RegularMessageType.TOPIC_SET_BY:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.TOPIC:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.WHO_IS:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.UNHANDLED:
      color = Colors.grey;
      break;
    case RegularMessageType.UNKNOWN:
      color = Colors.redAccent;
      break;
    case RegularMessageType.MESSAGE:
      color = Colors.grey;
      break;
    case RegularMessageType.JOIN:
      color = Colors.lightGreen;
      break;

    case RegularMessageType.AWAY:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.MODE:
      color = Colors.grey;
      break;
    case RegularMessageType.MOTD:
      color = Colors.grey;
      break;
    case RegularMessageType.NOTICE:
      color = Colors.grey;
      break;
    case RegularMessageType.ERROR:
      color = Colors.redAccent;
      break;
    case RegularMessageType.BACK:
      color = Colors.lightGreen;
      break;
    case RegularMessageType.MODE_CHANNEL:
      color = Colors.grey;
      break;
    case RegularMessageType.QUIT:
      color = Colors.redAccent;
      break;
    case RegularMessageType.RAW:
      color = Colors.grey;
      break;
    case RegularMessageType.PART:
      color = Colors.redAccent;
      break;
    case RegularMessageType.NICK:
      color = Colors.lightBlue;
      break;
  }
  return color;
}

IconData _findTitleIconDataForMessage(RegularMessage message) {
  IconData icon;
  switch (RegularMessage.regularMessageType(message)) {
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

bool isHaveLongText(RegularMessage message) =>
    message.text != null ? message.text.length > 10 : false;
