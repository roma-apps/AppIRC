import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/highlight/message_link_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_nickname_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_search_highlight.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/span_builder/span_builder.dart';

final int _longMessageTextMinimumLength = 10;
final String _paramsMessageBodyTextSeparator = ", ";

class RegularMessageWidget extends MessageWidget<RegularMessage> {
  RegularMessageWidget({
    @required RegularMessage message,
    @required bool enableMessageActions,
    @required MessageInListState messageInListState,
    @required MessageWidgetType messageWidgetType,
  }) : super(
          message: message,
          messageInListState: messageInListState,
          enableMessageActions: enableMessageActions,
          messageWidgetType: messageWidgetType,
        );

  @override
  Widget buildMessageBody(BuildContext context, ChatMessage message) {
    switch (messageWidgetType) {
      case MessageWidgetType.formatted:
        return _buildFormattedBody(context);
        break;
      case MessageWidgetType.raw:
        return buildMessageRawBody(
          context,
          message,
          getBodyRawText(context),
        );
        break;

      default:
        throw "Invalid message widget type $messageWidgetType";
    }
  }

  MultiChildRenderObjectWidget _buildFormattedBody(BuildContext context) {
    var color = findMessageColorByType(message.regularMessageType);

    var spans = <InlineSpan>[];
    spans.add(
      buildMessageDateTextSpan(
        context: context,
        date: message.date,
        color: color,
      ),
    );

    var messageIcon = _getMessageIcon(message);
    if (messageIcon != null) {
      spans
          .add(buildMessageIconWidgetSpan(iconData: messageIcon, color: color));
    }

    if (message.fromNick?.isNotEmpty == true) {
      spans.add(
        buildHighlightedNicknameButtonWidgetSpan(
          context: context,
          nick: message.fromNick,
        ),
      );
    }

    var title = _getMessageTitleString(context, message);

    if (title?.isNotEmpty == true) {
      spans.add(
        buildMessageTitleTextSpan(
          context: context,
          title: title,
          color: color,
        ),
      );
    }

    var isNeedDisplayText = true;
    isNeedDisplayText = _calculateIsNeedToDisplayMessageText(message);

    if (isNeedDisplayText) {
      spans.addAll(
        createMessageTextSpans(
          context: context,
          message: message,
          isHighlightedBySearch: messageInListState.inSearchResult,
        ),
      );
    }

    if (message.previews?.isNotEmpty == true) {
      var children = <Widget>[buildMessageRichText(spans)];
      message.previews.forEach(
          (preview) => children.add(buildPreview(context, message, preview)));
      return Column(children: children);
    } else {
      return buildMessageRichText(spans);
    }
  }

  @override
  String getBodyRawText(BuildContext context) {
    if (message.params != null) {
      return """${message.params}
      ${message.text}""";
    } else {
      return message.text;
    }
  }

  List<InlineSpan> createMessageTextSpans(
      {@required BuildContext context,
      @required RegularMessage message,
      @required bool isHighlightedBySearch}) {
    var spans = <InlineSpan>[];
    var params = message.params;

    if (params != null) {
      spans.add(
        TextSpan(
          text: "${params.join(_paramsMessageBodyTextSeparator)}",
          style: IAppIrcUiTextTheme.of(context)
              .mediumDarkGrey
              .copyWith(fontFamily: messagesFontFamily),
        ),
      );
    }

    if (message.text != null) {
      var text = message.text;
      var spanBuilders = <SpanBuilder>[];

      spanBuilders.addAll(
        message.linksInMessage?.map(
              (link) => buildLinkHighlighter(
                context: context,
                link: link,
              ),
            ) ??
            [],
      );
      spanBuilders.addAll(message.nicknames?.map(
            (nickname) => buildNicknameSpanHighlighter(
              context: context,
              nickname: nickname,
            ),
          ) ??
          []);
      if (isHighlightedBySearch) {
        String searchTerm = messageInListState.searchTerm;
        spanBuilders.add(
          buildSearchSpanHighlighter(
            context: context,
            searchTerm: searchTerm,
          ),
        );
      }
      spans.addAll(
        createSpans(
          context: context,
          text: text,
          defaultTextStyle: IAppIrcUiTextTheme.of(context)
              .mediumDarkGrey
              .copyWith(fontFamily: messagesFontFamily),
          spanBuilders: spanBuilders,
        ),
      );
    }

    return spans;
  }
}

TextSpan buildMessageTitleTextSpan({
  @required BuildContext context,
  @required String title,
  @required Color color,
}) {
  return TextSpan(
    text: "$title ",
    style: IAppIrcUiTextTheme.of(context)
        .mediumBoldDarkGrey
        .copyWith(fontFamily: messagesFontFamily),
  );
}

bool _calculateIsNeedToDisplayMessageText(RegularMessage message) {
  var isNeedDisplay = true;
  var regularMessageType = message.regularMessageType;
  if (regularMessageType == RegularMessageType.away ||
      regularMessageType == RegularMessageType.join ||
      regularMessageType == RegularMessageType.topicSetBy ||
      regularMessageType == RegularMessageType.motd ||
      regularMessageType == RegularMessageType.modeChannel ||
      regularMessageType == RegularMessageType.back) {
    isNeedDisplay = false;
  }
  if (regularMessageType == RegularMessageType.mode) {
    if (!_isHaveLongText(message)) {
      isNeedDisplay = false;
    }
  }
  return isNeedDisplay;
}

bool isHighlightedByServer(RegularMessage message) =>
    message.highlight == true ||
    message.regularMessageType == RegularMessageType.unknown;

String _getMessageTitleString(BuildContext context, RegularMessage message) {
  var regularMessageType = message.regularMessageType;

  String title;
  switch (regularMessageType) {
    case RegularMessageType.topicSetBy:
      title = S.of(context).chat_message_regular_sub_message_topic_set_by;
      break;
    case RegularMessageType.topic:
      title = S.of(context).chat_message_regular_sub_message_topic;
      break;
    case RegularMessageType.whoIs:
      title = S.of(context).chat_message_regular_sub_message_who_is;
      break;
    case RegularMessageType.unhandled:
      title = null;
      break;
    case RegularMessageType.unknown:
      title = S.of(context).chat_message_regular_sub_message_unknown;
      break;
    case RegularMessageType.message:
      title = null;
      break;
    case RegularMessageType.join:
      title = S.of(context).chat_message_regular_sub_message_join;
      break;
    case RegularMessageType.mode:
      if (_isHaveLongText(message)) {
        title = S.of(context).chat_message_regular_sub_message_mode_long;
      } else {
        title = S
            .of(context)
            .chat_message_regular_sub_message_mode_short(message.text);
      }

      break;
    case RegularMessageType.motd:
      title = S.of(context).chat_message_regular_sub_message_motd(
            message.text,
          );
      break;
    case RegularMessageType.notice:
      title = S.of(context).chat_message_regular_sub_message_notice;
      break;
    case RegularMessageType.monospaceBlock:
      // same as notice
      title = S.of(context).chat_message_regular_sub_message_notice;
      break;
    case RegularMessageType.error:
      title = S.of(context).chat_message_regular_sub_message_error;
      break;
    case RegularMessageType.away:
      title = S.of(context).chat_message_regular_sub_message_away;
      break;
    case RegularMessageType.back:
      title = S.of(context).chat_message_regular_sub_message_back;
      break;
    case RegularMessageType.modeChannel:
      title = S.of(context).chat_message_regular_sub_message_channel_mode(
            message.text,
          );

      break;
    case RegularMessageType.quit:
      title = S.of(context).chat_message_regular_sub_message_quit;
      break;
    case RegularMessageType.raw:
      title = null;
      break;
    case RegularMessageType.part:
      title = S.of(context).chat_message_regular_sub_message_part;
      break;
    case RegularMessageType.nick:
      title = S.of(context).chat_message_regular_sub_message_nick(
            message.newNick,
          );
      break;
    case RegularMessageType.ctcpRequest:
      title = S.of(context).chat_message_regular_sub_message_ctcp_request;
      break;
    case RegularMessageType.chghost:
      title = S.of(context).chat_message_regular_sub_message_chghost;
      break;
    case RegularMessageType.kick:
      title = S.of(context).chat_message_regular_sub_message_kick;
      break;
    case RegularMessageType.action:
      title = "";
      break;
    case RegularMessageType.invite:
      title = S.of(context).chat_message_regular_sub_message_invite;
      break;
    case RegularMessageType.ctcp:
      title = S.of(context).chat_message_regular_sub_message_ctcp;
      break;
  }
  return title;
}

bool _isHaveLongText(RegularMessage message) => message.text != null
    ? message.text.length > _longMessageTextMinimumLength
    : false;

IconData _getMessageIcon(RegularMessage message) {
  IconData icon;
  switch (message.regularMessageType) {
    case RegularMessageType.topicSetBy:
      icon = Icons.assistant_photo;
      break;
    case RegularMessageType.topic:
      icon = Icons.title;
      break;
    case RegularMessageType.whoIs:
      icon = Icons.account_circle;
      break;
    case RegularMessageType.unhandled:
      icon = Icons.info;
      break;
    case RegularMessageType.unknown:
      icon = Icons.help;
      break;
    case RegularMessageType.message:
      // nothing. We don't need icon for simple message
      icon = null;
      break;
    case RegularMessageType.join:
      icon = Icons.arrow_forward;
      break;

    case RegularMessageType.away:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.mode:
      icon = Icons.info;
      break;
    case RegularMessageType.motd:
      icon = Icons.info;
      break;
    case RegularMessageType.notice:
      icon = Icons.info;
      break;
    case RegularMessageType.monospaceBlock:
      icon = Icons.info;
      break;
    case RegularMessageType.error:
      icon = Icons.error;
      break;
    case RegularMessageType.back:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.modeChannel:
      icon = Icons.info;
      break;
    case RegularMessageType.quit:
      icon = Icons.exit_to_app;
      break;
    case RegularMessageType.raw:
      icon = Icons.info;
      break;
    case RegularMessageType.part:
      icon = Icons.arrow_forward;
      break;
    case RegularMessageType.nick:
      icon = Icons.accessibility_new;
      break;
    case RegularMessageType.ctcpRequest:
      icon = Icons.info;
      break;
    case RegularMessageType.chghost:
      icon = Icons.info;
      break;
    case RegularMessageType.kick:
      icon = Icons.info;
      break;
    case RegularMessageType.action:
      icon = Icons.star;
      break;
    case RegularMessageType.invite:
      icon = Icons.info;
      break;
    case RegularMessageType.ctcp:
      icon = Icons.info;
      break;
  }
  return icon;
}

Color findMessageColorByType(RegularMessageType regularMessageType) {
  Color color;
  switch (regularMessageType) {
    case RegularMessageType.topicSetBy:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.topic:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.whoIs:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.unhandled:
      color = Colors.grey;
      break;
    case RegularMessageType.unknown:
      color = Colors.redAccent;
      break;
    case RegularMessageType.message:
      color = Colors.grey;
      break;
    case RegularMessageType.join:
      color = Colors.lightGreen;
      break;

    case RegularMessageType.away:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.mode:
      color = Colors.grey;
      break;
    case RegularMessageType.motd:
      color = Colors.grey;
      break;
    case RegularMessageType.notice:
      color = Colors.grey;
      break;
    case RegularMessageType.monospaceBlock:
      color = Colors.grey;
      break;
    case RegularMessageType.error:
      color = Colors.redAccent;
      break;
    case RegularMessageType.back:
      color = Colors.lightGreen;
      break;
    case RegularMessageType.modeChannel:
      color = Colors.grey;
      break;
    case RegularMessageType.quit:
      color = Colors.redAccent;
      break;
    case RegularMessageType.raw:
      color = Colors.grey;
      break;
    case RegularMessageType.part:
      color = Colors.redAccent;
      break;
    case RegularMessageType.nick:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.ctcpRequest:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.chghost:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.kick:
      color = Colors.red;
      break;
    case RegularMessageType.action:
      color = Colors.lightBlue;
      break;
    case RegularMessageType.invite:
      color = Colors.lightGreen;
      break;
    case RegularMessageType.ctcp:
      color = Colors.lightBlue;
      break;
  }
  return color;
}
