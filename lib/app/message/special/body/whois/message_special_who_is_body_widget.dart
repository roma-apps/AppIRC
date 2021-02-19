import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_widget.dart';
import 'package:flutter_appirc/app/message/special/body/whois/message_special_who_is_body_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

class WhoIsSpecialMessageBodyWidget
    extends SpecialMessageBodyWidget<WhoIsSpecialMessageBody> {
  WhoIsSpecialMessageBodyWidget(
      {@required SpecialMessage message,
        @required WhoIsSpecialMessageBody body,
        @required bool inSearchResults,
        @required MessageWidgetType messageWidgetType})
      : super(
            message: message,
            body: body,
            inSearchResults: inSearchResults,
            messageWidgetType: messageWidgetType);

  @override
  Widget build(BuildContext context) {
    String actualHostNameValue = calculateActualHostName(body);



    var child = Column(
      children: <Widget>[
        _buildWhoIsRow(
            tr("chat.message.special.who_is.hostmask"),
            "${body.ident}@${body.hostname}"),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.actual_hostname"),
            actualHostNameValue),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.real_name"),
            body.realName),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.channels"),
            body.channels),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.secure_connection"),
            body.secure.toString()),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.connected_to"),
            "${body.server} (${body.serverInfo})"),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.account"),
            body.account),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.connected_at"),
            regularDateFormatter.format(body.logonTime)),
        _buildWhoIsRow(
            tr("chat.message.special.who_is.idle_since"),
            regularDateFormatter.format(body.idleTime)),
      ],
    );
    SpecialMessageSkinBloc messagesSpecialSkinBloc = Provider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildWhoIsSpecialMessageHeaderWidget(
            context: context,
            date: message.date,
            fromNick: body.nick,
            color: messagesSpecialSkinBloc.specialMessageColor,
            iconData: Icons.account_box),
        child
      ],
    );
  }

  @override
  String getBodyRawText(BuildContext context) {
    return _buildWhoIsRawBody(context: context, whoIsBody: body);
  }
}

Widget _buildWhoIsSpecialMessageHeaderWidget(
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
            Flexible(
                child: Text(
              value,
              softWrap: true,
            ))
          ]),
    );
  } else {
    return SizedBox.shrink();
  }
}

String _buildWhoIsRawBody(
    {@required BuildContext context,
    @required WhoIsSpecialMessageBody whoIsBody}) {
  String actualHostNameValue = calculateActualHostName(whoIsBody);



  var rawBody = _buildWhoIsRawRow(
          tr("chat.message.special.who_is"
              ".hostmask"),
          "${whoIsBody.ident}@${whoIsBody.hostname}") +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.actual_hostname"),
          actualHostNameValue) +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.real_name"),
          whoIsBody.realName) +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.channels"),
          whoIsBody.channels) +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.secure_connection"),
          whoIsBody.secure.toString()) +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.connected_to"),
          "${whoIsBody.server} (${whoIsBody.serverInfo})") +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.account"),
          whoIsBody.account) +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.connected_at"),
          regularDateFormatter.format(whoIsBody.logonTime)) +
      _buildWhoIsRawRow(
          tr("chat.message.special.who_is.idle_since"),
          regularDateFormatter.format(whoIsBody.idleTime));

  return rawBody;
}

String calculateActualHostName(WhoIsSpecialMessageBody whoIsBody) {
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
  return actualHostNameValue;
}

String _buildWhoIsRawRow(String label, String value) =>
    value != null ? "$label $value \n" : "";
