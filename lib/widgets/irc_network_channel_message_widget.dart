import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

var todayDateFormatter = new DateFormat().add_Hm();
var oldDateFormatter = new DateFormat().add_yMd().add_Hm();

class IRCNetworkChannelMessageWidget extends StatelessWidget {
  final IRCNetworkChannelMessage message;

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
    if (message.type == IRCNetworkChannelMessageType.AWAY ||
        message.type == IRCNetworkChannelMessageType.JOIN ||
        message.type == IRCNetworkChannelMessageType.TOPIC_SET_BY ||
        message.type == IRCNetworkChannelMessageType.MOTD ||
        message.type == IRCNetworkChannelMessageType.MODE_CHANNEL ||
        message.type == IRCNetworkChannelMessageType.BACK) {
      return Container();
    }
    if (message.type == IRCNetworkChannelMessageType.MODE) {
      if (!isHaveLongText(message)) {
        return Container();
      }
    }

    if (message.type == IRCNetworkChannelMessageType.MODE) {
      if (!isHaveLongText(message)) {
        return Container();
      }
    }

    var rows = <Widget>[
//      Text("${message.type}"),
    ];
    if (message.params != null) {
      rows.add(Text("${message.params.join(", ")}",
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
        linkStyle: uiSkin.appSkin.channelMessagesBodyTextStyle.copyWith(
            color: Colors.blue),
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

    if (message.isHaveFrom) {
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

    if (message.isMessageDateToday) {
      dateString = todayDateFormatter.format(message.date);
    } else {
      dateString = oldDateFormatter.format(message.date);
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
      message.from.nick,
      style: uiSkin.appSkin.channelMessagesNickTextStyle,
    );
  }

  _buildTitleIcon(IRCNetworkChannelMessage message) {
    var iconData = _findTitleIconDataForMessage(message);
    var color = _findTitleColorDataForMessage(message);

    return Icon(iconData, color: color);
  }

  Widget _buildTitleSubMessage(BuildContext context, UISkin uiSkin) {
    var appLocalizations = AppLocalizations.of(context);
    String str;
    switch (message.type) {
      case IRCNetworkChannelMessageType.TOPIC_SET_BY:
        str = appLocalizations.tr("chat.sub_message.topic_set_by");
        break;
      case IRCNetworkChannelMessageType.TOPIC:
        str = appLocalizations.tr("chat.sub_message.topic");
        break;
      case IRCNetworkChannelMessageType.WHO_IS:
        str = appLocalizations.tr("chat.sub_message.who_is");
        break;
      case IRCNetworkChannelMessageType.UNHANDLED:
        str = null;
        break;
      case IRCNetworkChannelMessageType.UNKNOWN:
        str = appLocalizations.tr("chat.sub_message.unknown");
        break;
      case IRCNetworkChannelMessageType.MESSAGE:
        str = null;
        break;
      case IRCNetworkChannelMessageType.JOIN:
        str = appLocalizations.tr("chat.sub_message.join");
        break;
      case IRCNetworkChannelMessageType.MODE:
        if (isHaveLongText(message)) {
          str = appLocalizations.tr("chat.sub_message.mode_long");
        } else {
          str = appLocalizations
              .tr("chat.sub_message.mode_short", args: [message.text]);
        }

        break;
      case IRCNetworkChannelMessageType.MOTD:
        str =
            appLocalizations.tr("chat.sub_message.motd", args: [message.text]);
        break;
      case IRCNetworkChannelMessageType.NOTICE:
        str = appLocalizations.tr("chat.sub_message.notice");
        break;
      case IRCNetworkChannelMessageType.ERROR:
        str = appLocalizations.tr("chat.sub_message.error");
        break;
      case IRCNetworkChannelMessageType.AWAY:
        str = appLocalizations.tr("chat.sub_message.away");
        break;
      case IRCNetworkChannelMessageType.BACK:
        str = appLocalizations.tr("chat.sub_message.back");
        break;
      case IRCNetworkChannelMessageType.MODE_CHANNEL:
        str = appLocalizations
            .tr("chat.sub_message.channel_mode", args: [message.text]);
        break;
      case IRCNetworkChannelMessageType.QUIT:
        str = appLocalizations.tr("chat.sub_message.quit");
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

isNeedHighlight(IRCNetworkChannelMessage message) =>
    message.highlight == true ||
        message.type ==
            IRCNetworkChannelMessageType.UNKNOWN; // TODO: remove debug UNKNOWN

Color _findTitleColorDataForMessage(IRCNetworkChannelMessage message) {
  Color color;
  switch (message.type) {
    case IRCNetworkChannelMessageType.TOPIC_SET_BY:
      color = Colors.lightBlue;
      break;
    case IRCNetworkChannelMessageType.TOPIC:
      color = Colors.lightBlue;
      break;
    case IRCNetworkChannelMessageType.WHO_IS:
      color = Colors.lightBlue;
      break;
    case IRCNetworkChannelMessageType.UNHANDLED:
      color = Colors.grey;
      break;
    case IRCNetworkChannelMessageType.UNKNOWN:
      color = Colors.redAccent;
      break;
    case IRCNetworkChannelMessageType.MESSAGE:
      color = Colors.grey;
      break;
    case IRCNetworkChannelMessageType.JOIN:
      color = Colors.lightGreen;
      break;

    case IRCNetworkChannelMessageType.AWAY:
      color = Colors.lightBlue;
      break;
    case IRCNetworkChannelMessageType.MODE:
      color = Colors.grey;
      break;
    case IRCNetworkChannelMessageType.MOTD:
      color = Colors.grey;
      break;
    case IRCNetworkChannelMessageType.NOTICE:
      color = Colors.grey;
      break;
    case IRCNetworkChannelMessageType.ERROR:
      color = Colors.redAccent;
      break;
    case IRCNetworkChannelMessageType.BACK:
      color = Colors.lightGreen;
      break;
    case IRCNetworkChannelMessageType.MODE_CHANNEL:
      color = Colors.grey;
      break;
    case IRCNetworkChannelMessageType.QUIT:
      color = Colors.redAccent;
      break;
  }
  return color;
}

IconData _findTitleIconDataForMessage(IRCNetworkChannelMessage message) {
  IconData icon;
  switch (message.type) {
    case IRCNetworkChannelMessageType.TOPIC_SET_BY:
      icon = Icons.assistant_photo;
      break;
    case IRCNetworkChannelMessageType.TOPIC:
      icon = Icons.title;
      break;
    case IRCNetworkChannelMessageType.WHO_IS:
      icon = Icons.account_circle;
      break;
    case IRCNetworkChannelMessageType.UNHANDLED:
      icon = Icons.info;
      break;
    case IRCNetworkChannelMessageType.UNKNOWN:
      icon = Icons.help;
      break;
    case IRCNetworkChannelMessageType.MESSAGE:
      icon = Icons.message;
      break;
    case IRCNetworkChannelMessageType.JOIN:
      icon = Icons.arrow_forward;
      break;

    case IRCNetworkChannelMessageType.AWAY:
      icon = Icons.arrow_forward;
      break;
    case IRCNetworkChannelMessageType.MODE:
      icon = Icons.info;
      break;
    case IRCNetworkChannelMessageType.MOTD:
      icon = Icons.info;
      break;
    case IRCNetworkChannelMessageType.NOTICE:
      icon = Icons.info;
      break;
    case IRCNetworkChannelMessageType.ERROR:
      icon = Icons.error;
      break;
    case IRCNetworkChannelMessageType.BACK:
      icon = Icons.arrow_forward;
      break;
    case IRCNetworkChannelMessageType.MODE_CHANNEL:
      icon = Icons.info;
      break;
    case IRCNetworkChannelMessageType.QUIT:
      icon = Icons.exit_to_app;
      break;
  }
  return icon;
}

bool isHaveLongText(IRCNetworkChannelMessage message) =>
    message.text != null ? message.text.length > 10 : false;
