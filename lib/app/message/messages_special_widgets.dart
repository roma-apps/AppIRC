import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/messages_regular_body_widget.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/message/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/message/messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/user/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildSpecialMessageWidget(
    BuildContext context, SpecialMessage specialMessage) {
  switch (specialMessage.specialType) {
    case SpecialMessageType.WHO_IS:
      return _buildWhoIsMessage(context, specialMessage);
      break;
    case SpecialMessageType.CHANNELS_LIST_ITEM:
      var channelInfoItem =
          specialMessage.data as NetworkChannelInfoSpecialMessageBody;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildChannelName(context, channelInfoItem),
                _buildUsersCount(context, channelInfoItem),
              ],
            ),
            _buildTopic(context, channelInfoItem.topic),
          ],
        ),
      );
      break;
    case SpecialMessageType.TEXT:
      var textSpecialMessage = specialMessage.data as TextSpecialMessageBody;
      return Text(textSpecialMessage.message);
  }
  throw Exception("Invalid message type $specialMessage");
}

Widget _buildWhoIsMessage(BuildContext context, SpecialMessage message) {
  WhoIsSpecialMessageBody whoIsBody = message.data as WhoIsSpecialMessageBody;
  String actualHostNameValue;

  if (whoIsBody.actualIp != null || whoIsBody.actualHostname != null) {
    if (whoIsBody.actualIp != null && whoIsBody.actualHostname != null) {
      if (whoIsBody.actualIp != whoIsBody.actualHostname) {
        actualHostNameValue =
            "${whoIsBody.actualIp}@${whoIsBody.actualHostname}";
      } else {
        actualHostNameValue = "${whoIsBody.actualIp}";
      }
    } else {
      if (whoIsBody.actualIp != null) {
        actualHostNameValue = "${whoIsBody.actualIp}";
      } else if (whoIsBody.actualHostname != null) {
        actualHostNameValue = "${whoIsBody.actualHostname}";
      }
    }
  }

  var appLocalizations = AppLocalizations.of(context);

  var body = Column(
    children: <Widget>[
      _buildWhoIsRow(appLocalizations.tr("chat.who_is.hostmask"),
          "${whoIsBody.ident}@${whoIsBody.hostname}"),
      _buildWhoIsRow(appLocalizations.tr("chat.who_is.actual_hostname"),
          actualHostNameValue),
      _buildWhoIsRow(
          appLocalizations.tr("chat.who_is.real_name"), whoIsBody.realName),
      _buildWhoIsRow(
          appLocalizations.tr("chat.who_is.channels"), whoIsBody.channels),
      _buildWhoIsRow(appLocalizations.tr("chat.who_is.secure_connection"),
          whoIsBody.secure.toString()),
      _buildWhoIsRow(appLocalizations.tr("chat.who_is.connected_to"),
          "${whoIsBody.server} (${whoIsBody.serverInfo})"),
      _buildWhoIsRow(
          appLocalizations.tr("chat.who_is.account"), whoIsBody.account),
      _buildWhoIsRow(appLocalizations.tr("chat.who_is.connected_at"),
          regularDateFormatter.format(whoIsBody.logonTime)),
      _buildWhoIsRow(appLocalizations.tr("chat.who_is.idle_since"),
          regularDateFormatter.format(whoIsBody.idleTime)),
//      _buildWhoIsRow("Logon", whoIsBody.logon),
    ],
  );
  var color = Colors.blue;
  var channelBloc = NetworkChannelBloc.of(context);

  var nickNamesBloc = Provider.of<ColoredNicknamesBloc>(context);
  var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);
  var nick = whoIsBody.nick;
  var child = Text(
    nick,
    style:
        messagesSkin.createNickTextStyle(nickNamesBloc.getColorForNick(nick)),
  );

  Widget title = buildMessageTitle(
      buildUserNickWithPopupMenu(context, child, nick, channelBloc),
      Row(
        children: <Widget>[
          buildMessageTitleDate(context, message, color),
          buildMessageIcon(Icons.account_box, color)
        ],
      ));
  return buildRegularMessageWidget(context, title, body, false, null);
}

Widget _buildWhoIsRow(String label, String value) {
  if (value != null) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
              child: Text(label),
            ),
            Flexible(child: Text(value))
          ]),
    );
  } else {
    return SizedBox.shrink();
  }
}

Widget _buildUsersCount(BuildContext context,
    NetworkChannelInfoSpecialMessageBody channelInfoItem) {
  return Text(AppLocalizations.of(context).tr("channels_list.users",
      args: [channelInfoItem.usersCount.toString()]));
}

Widget _buildChannelName(BuildContext context,
    NetworkChannelInfoSpecialMessageBody channelInfoItem) {
  var channelName = channelInfoItem.name;
  var password = ""; // channels list contains only channels without password
  MessagesSpecialSkinBloc messagesSpecialSkinBloc =
      Provider.of<MessagesSpecialSkinBloc>(context);
  return GestureDetector(
      onTap: () {
        NetworkBloc networkBloc = NetworkBloc.of(context);

        networkBloc.joinNetworkChannel(ChatNetworkChannelPreferences.name(
            name: channelName, password: password));
      },
      child: Text(
        channelName,
        style: TextStyle(color: messagesSpecialSkinBloc.linkColor),
      ));
}

Widget _buildTopic(BuildContext context, String topic) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
child: buildRegularMessageBody(context, topic),
//    child: Linkify(
//        onOpen: (link) async {
//          if (await canLaunch(link.url)) {
//            await launch(link.url);
//          } else {
//            throw 'Could not launch $link';
//          }
//        },
//        text: topic
//    ),
  );
}
