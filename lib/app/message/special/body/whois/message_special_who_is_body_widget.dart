import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_widget.dart';
import 'package:flutter_appirc/app/message/special/body/whois/message_special_who_is_body_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';

class WhoIsSpecialMessageBodyWidget
    extends SpecialMessageBodyWidget<WhoIsSpecialMessageBody> {
  WhoIsSpecialMessageBodyWidget({
    @required SpecialMessage message,
    @required WhoIsSpecialMessageBody body,
    @required bool inSearchResults,
    @required MessageWidgetType messageWidgetType,
  }) : super(
            message: message,
            body: body,
            inSearchResults: inSearchResults,
            messageWidgetType: messageWidgetType);

  @override
  Widget build(BuildContext context) {
    String actualHostNameValue = calculateActualHostName(
      body,
    );

    var child = Column(
      children: <Widget>[
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_hostmask,
          "${body.ident}@${body.hostname}",
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_actual_hostname,
          actualHostNameValue,
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_real_name,
          body.realName,
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_channels,
          body.channels,
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_secure_connection,
          body.secure.toString(),
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_connected_to,
          "${body.server} (${body.serverInfo})",
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_account,
          body.account,
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_connected_at,
          regularDateFormatter.format(
            body.logonTime,
          ),
        ),
        _buildWhoIsRow(
          context,
          S.of(context).chat_message_special_who_is_idle_since,
          regularDateFormatter.format(
            body.idleTime,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildWhoIsSpecialMessageHeaderWidget(
          context: context,
          date: message.date,
          fromNick: body.nick,
          color: IAppIrcUiColorTheme.of(context).primaryDark,
          iconData: Icons.account_box,
        ),
        child,
      ],
    );
  }

  @override
  String getBodyRawText(BuildContext context) {
    return _buildWhoIsRawBody(
      context: context,
      whoIsBody: body,
    );
  }
}

Widget _buildWhoIsSpecialMessageHeaderWidget({
  @required BuildContext context,
  @required DateTime date,
  @required String fromNick,
  @required IconData iconData,
  @required Color color,
}) {
  var spans = <InlineSpan>[];
  spans.add(
    buildMessageDateTextSpan(
      context: context,
      date: date,
      color: color,
    ),
  );

  spans.add(
    buildMessageIconWidgetSpan(
      iconData: iconData,
      color: color,
    ),
  );

  if (fromNick?.isNotEmpty == true) {
    spans.add(
      buildHighlightedNicknameButtonWidgetSpan(
        context: context,
        nick: fromNick,
      ),
    );
  }

  return buildMessageRichText(spans);
}

Widget _buildWhoIsRow(BuildContext context, String label, String value) {
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
              style: IAppIrcUiTextTheme.of(context)
                  .mediumDarkGrey
                  .copyWith(fontFamily: messagesFontFamily),
            ),
          )
        ],
      ),
    );
  } else {
    return SizedBox.shrink();
  }
}

String _buildWhoIsRawBody({
  @required BuildContext context,
  @required WhoIsSpecialMessageBody whoIsBody,
}) {
  String actualHostNameValue = calculateActualHostName(whoIsBody);

  var rawBody = _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_hostmask,
        "${whoIsBody.ident}@${whoIsBody.hostname}",
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_actual_hostname,
        actualHostNameValue,
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_real_name,
        whoIsBody.realName,
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_channels,
        whoIsBody.channels,
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_secure_connection,
        whoIsBody.secure.toString(),
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_connected_to,
        "${whoIsBody.server} (${whoIsBody.serverInfo})",
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_account,
        whoIsBody.account,
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_connected_at,
        regularDateFormatter.format(
          whoIsBody.logonTime,
        ),
      ) +
      _buildWhoIsRawRow(
        S.of(context).chat_message_special_who_is_idle_since,
        regularDateFormatter.format(
          whoIsBody.idleTime,
        ),
      );

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
