import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';

class IRCNetworkChannelMessageWidget extends StatelessWidget {
  final IRCNetworkChannelMessage message;

  IRCNetworkChannelMessageWidget(this.message);

  @override
  Widget build(BuildContext context) {
    var uiSkin = UISkin.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: _buildMessageTitle(context, uiSkin),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: _buildMessageBody(context, uiSkin),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBody(BuildContext context, UISkin uiSkin) {



    var rows = <Widget>[
        Text("${message.type}"),
      ];
    if(message.params != null) {
      rows.add(Text("${message.params.join(", ")}"));
    }

    if(message.text != null) {
      rows.add(Text("${message.text}"));
    }

    return Column(
      children: rows,
    );
  }

  Row _buildMessageTitle(BuildContext context, UISkin uiSkin) {
    var  list = <Widget>[
      _buildMessageTitleDate(uiSkin),
    ];
    if (message.isHaveFrom) {
      list.insert(0, _buildMessageTitleNick(uiSkin));
    }

    var icon = _buildTitleIcon(message);

    if (icon != null) {
      list.add(icon);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: list,
    );
  }

  Padding _buildMessageTitleDate(UISkin uiSkin) {
    var dateString;

    if (message.isMessageDateToday) {
      dateString = message.date.toString();
    } else {
      dateString = message.date.toString();
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        dateString,
        style: uiSkin.appSkin.channelMessagesDateTextStyle,
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
    var icon;
    switch(message.type) {

      case IRCNetworkChannelMessageType.TOPIC_SET_BY:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.TOPIC:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.WHO_IS:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.UNHANDLED:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.UNKNOWN:
        icon = Icon(Icons.help, color: Colors.redAccent);
        break;
      case IRCNetworkChannelMessageType.MESSAGE:
        icon = Icon(Icons.message, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.JOIN:
        icon = Icon(Icons.arrow_forward, color: Colors.lightGreen);
        break;

      case IRCNetworkChannelMessageType.AWAY:
        icon = Icon(Icons.arrow_forward, color: Colors.lightBlue);
        break;
      case IRCNetworkChannelMessageType.MODE:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.MOTD:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.NOTICE:
        icon = Icon(Icons.info, color: Colors.grey);
        break;
      case IRCNetworkChannelMessageType.ERROR:
        icon = Icon(Icons.error, color: Colors.redAccent);
        break;
      case IRCNetworkChannelMessageType.BACK:
        icon = Icon(Icons.arrow_forward, color: Colors.lightGreen);
        break;
    }
    return icon;
  }


}
