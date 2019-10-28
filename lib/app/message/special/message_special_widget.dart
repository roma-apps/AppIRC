import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/message/highlight/message_link_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_search_highlight.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter.dart';

Widget buildSpecialMessageWidget(BuildContext context,
    SpecialMessage specialMessage, bool includedInSearch, String searchTerm) {
  switch (specialMessage.specialType) {
    case SpecialMessageType.whoIs:
      return _buildWhoIsMessage(context, specialMessage);
      break;
    case SpecialMessageType.channelsListItem:
      var channelInfoItem =
          specialMessage.data as ChannelInfoSpecialMessageBody;
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
            _buildTopic(context, channelInfoItem.topic,
                specialMessage.linksInText, includedInSearch, searchTerm),
          ],
        ),
      );
      break;
    case SpecialMessageType.text:
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
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.hostmask"),
          "${whoIsBody.ident}@${whoIsBody.hostname}"),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.actual_hostname"),
          actualHostNameValue),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.real_name"),
          whoIsBody.realName),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.channels"),
          whoIsBody.channels),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.secure_connection"),
          whoIsBody.secure.toString()),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.connected_to"),
          "${whoIsBody.server} (${whoIsBody.serverInfo})"),
      _buildWhoIsRow(appLocalizations.tr("chat.message.special.who_is.account"),
          whoIsBody.account),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.connected_at"),
          regularDateFormatter.format(whoIsBody.logonTime)),
      _buildWhoIsRow(
          appLocalizations.tr("chat.message.special.who_is.idle_since"),
          regularDateFormatter.format(whoIsBody.idleTime)),
//      _buildWhoIsRow("Logon", whoIsBody.logon),
    ],
  );
  MessagesSpecialSkinBloc messagesSpecialSkinBloc = Provider.of(context);
  var color = messagesSpecialSkinBloc.specialMessageColor;
  var nick = whoIsBody.nick;

  Widget title = buildMessageTitle(
      buildUserNickWithPopupMenu(
          context: context, nick: nick, actionCallback: null),
      Row(
        children: <Widget>[
          buildMessageTitleDate(
              context: context, message: message, color: color),
          Icon(Icons.account_box, color: color)
        ],
      ));
  return buildMessageWidget(context:context, title:title, body:body,
      color: null);
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
    ChannelInfoSpecialMessageBody channelInfoItem) {
  return Text(AppLocalizations.of(context).tr(
      "chat"
      ".message_special.channels_list.users",
      args: [channelInfoItem.usersCount.toString()]));
}

Widget _buildChannelName(BuildContext context,
    ChannelInfoSpecialMessageBody channelInfoItem) {
  var channelName = channelInfoItem.name;
  var password = ""; // channels list contains only channels without password
  MessageSkinBloc messagesSkinBloc = Provider.of(context);
  return GestureDetector(
      onTap: () {
        NetworkBloc networkBloc = NetworkBloc.of(context);

        networkBloc.joinChannel(ChannelPreferences.name(
            name: channelName, password: password));
      },
      child: Text(
        channelName,
        style: messagesSkinBloc.linkTextStyle,
      ));
}

Widget _buildTopic(BuildContext context, String topic, List<String> linksInText,
    bool includedInSearch, String searchTerm) {
  MessagesSpecialSkinBloc messagesSpecialSkinBloc =
      Provider.of<MessagesSpecialSkinBloc>(context);

  var spanBuilders = [];
  spanBuilders.addAll(linksInText.map(
      (link) => buildLinkHighlighter(context: context, link: link)));
  if (includedInSearch) {
    spanBuilders.add(buildSearchSpanHighlighter(
        context: context, searchTerm: searchTerm));
  }
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: buildWordSpannedRichText(
        context, topic, messagesSpecialSkinBloc.defaultTextStyle, spanBuilders),
  );
}
