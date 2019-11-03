import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/message/highlight/message_link_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_search_highlight.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';

Widget _buildSpecialMessageHeaderWidget(
    {@required BuildContext context,
    @required DateTime date,
    @required String fromNick,
    @required IconData iconData,
    @required Color color}) {
  var spans = <InlineSpan>[];
  spans.add(
      buildMessageDateTextSpan(context: context, date: date, color: color));

  spans.add(buildMessageIconWidgetSpan(iconData: iconData, color: color));

  if (fromNick?.isNotEmpty == true) {
    spans.add(buildHighlightedNicknameButtonWidgetSpan(
        context: context, nick: fromNick));
  }

  return buildMessageRichText(spans);
}

Widget buildSpecialMessageWidget(
    {@required BuildContext context,
    @required SpecialMessage message,
    @required bool includedInSearch,
    @required String searchTerm}) {
  switch (message.specialType) {
    case SpecialMessageType.whoIs:
      WhoIsSpecialMessageBody whoIsBody =
          message.data as WhoIsSpecialMessageBody;
      return _buildWhoIsSpecialMessageWidget(
          context: context, whoIsBody: whoIsBody, message: message);
      break;
    case SpecialMessageType.channelsListItem:
      var channelInfoItem = message.data as ChannelInfoSpecialMessageBody;
      return _buildChannelInfoSpecialMessageWidget(
          context: context,
          channelInfoItem: channelInfoItem,
          linksInText: message.linksInText,
          includedInSearch: includedInSearch,
          searchTerm: searchTerm);
      break;
    case SpecialMessageType.text:
      var textSpecialMessage = message.data as TextSpecialMessageBody;
      return _buildTextSpecialMessageWidget(
          textSpecialMessage: textSpecialMessage);
  }
  throw Exception("Invalid message type $message");
}

Padding _buildTextSpecialMessageWidget(
    {@required TextSpecialMessageBody textSpecialMessage}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(textSpecialMessage.message),
  );
}

Padding _buildChannelInfoSpecialMessageWidget(
    {@required BuildContext context,
    @required ChannelInfoSpecialMessageBody channelInfoItem,
    @required List<String> linksInText,
    @required bool includedInSearch,
    @required String searchTerm}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildChannelInfoName(
                context: context, channelName: channelInfoItem.name),
            _buildChannelInfoUsersCount(
                context: context, usersCount: channelInfoItem.usersCount),
          ],
        ),
        _buildChannelInfoTopic(
            context: context,
            topic: channelInfoItem.topic,
            linksInText: linksInText,
            includedInSearch: includedInSearch,
            searchTerm: searchTerm),
      ],
    ),
  );
}

Widget _buildWhoIsSpecialMessageWidget(
    {@required BuildContext context,
    @required SpecialMessage message,
    @required WhoIsSpecialMessageBody whoIsBody}) {
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
    ],
  );
  SpecialMessageSkinBloc messagesSpecialSkinBloc = Provider.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _buildSpecialMessageHeaderWidget(
          context: context,
          date: message.date,
          fromNick: whoIsBody.nick,
          color: messagesSpecialSkinBloc.specialMessageColor,
          iconData: Icons.account_box),
      body
    ],
  );
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
            Flexible(child: Text(value, softWrap: true,))
          ]),
    );
  } else {
    return SizedBox.shrink();
  }
}

Widget _buildChannelInfoUsersCount(
    {@required BuildContext context, @required int usersCount}) {
  return Text(AppLocalizations.of(context).tr(
      "chat"
      ".message.special.channels_list.users",
      args: [usersCount.toString()]));
}

Widget _buildChannelInfoName(
    {@required BuildContext context, @required String channelName}) {
  var password = ""; // channels list contains only channels without password
  MessageSkinBloc messagesSkinBloc = Provider.of(context);
  return GestureDetector(
      onTap: () {
        NetworkBloc networkBloc = NetworkBloc.of(context);

        networkBloc.joinChannel(
            ChannelPreferences.name(name: channelName, password: password));
      },
      child: Text(
        channelName,
        style: messagesSkinBloc.linkTextStyle,
      ));
}

Widget _buildChannelInfoTopic(
    {@required BuildContext context,
    @required String topic,
    @required List<String> linksInText,
    @required bool includedInSearch,
    @required String searchTerm}) {
  MessageSkinBloc messageSkinBloc = Provider.of(context);

  var spanBuilders = <SpanBuilder>[];
  spanBuilders.addAll(linksInText
      .map((link) => buildLinkHighlighter(context: context, link: link)));
  if (includedInSearch) {
    spanBuilders.add(
        buildSearchSpanHighlighter(context: context, searchTerm: searchTerm));
  }
  var spans = createSpans(
      context: context,
      text: topic,
      defaultTextStyle: messageSkinBloc.messageBodyTextStyle,
      spanBuilders: spanBuilders);
  return Padding(
      padding: const EdgeInsets.all(8.0), child: buildMessageRichText(spans));
}
