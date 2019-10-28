import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/highlight/message_link_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_nickname_highlight.dart';
import 'package:flutter_appirc/app/message/highlight/message_search_highlight.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_widget.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/span_highlighter/span_highlighter.dart';

final int _longMessageTextMinimumLength = 10;

Widget buildRegularMessage(BuildContext context, RegularMessage message,
    bool isHighlightedBySearch, String searchTerm) {
  var channelBloc = ChannelBloc.of(context);

  var body =
      _buildMessageBody(context, message, isHighlightedBySearch, searchTerm);

  var title = _buildMessageTitle(context, channelBloc, message);

  var subMessage = _buildTitleSubMessage(context, message);

  if (subMessage != null) {
    body = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[subMessage, body]);
  }

  var messagesSkin = Provider.of<MessageRegularSkinBloc>(context);

  var color =
      messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

  return buildMessageWidget(
      context: context, title: title, body: body, color: color);
}

Widget _buildMessageBody(BuildContext context, RegularMessage message,
    bool isHighlightedBySearch, String searchTerm) {
  var regularMessageType = message.regularMessageType;

  if (regularMessageType == RegularMessageType.away ||
      regularMessageType == RegularMessageType.join ||
      regularMessageType == RegularMessageType.topicSetBy ||
      regularMessageType == RegularMessageType.motd ||
      regularMessageType == RegularMessageType.modeChannel ||
      regularMessageType == RegularMessageType.back) {
    return SizedBox.shrink();
  }
  if (regularMessageType == RegularMessageType.mode) {
    if (!_isHaveLongText(message)) {
      return SizedBox.shrink();
    }
  }

  var messagesRegularSkin = Provider.of<MessageRegularSkinBloc>(context);

  var children = <Widget>[];

  var params = message.params;

  if (params != null) {
    var paramsTextWidget = Text("${params.join(", ")}",
        style: messagesRegularSkin.regularMessageBodyTextStyle);
    children.add(paramsTextWidget);
  }

  if (message.text != null) {
    var text = message.text;
    var spanBuilders = [];

    spanBuilders.addAll(message.linksInText
        .map((link) => buildLinkHighlighter(context: context, link: link)));
    spanBuilders.addAll(message.nicknames.map((nickname) =>
        buildNicknameSpanHighlighter(context: context, nickname: nickname)));
    if (isHighlightedBySearch) {
      spanBuilders.add(
          buildSearchSpanHighlighter(context: context, searchTerm: searchTerm));
    }
    var highlightedTextWidget = buildWordSpannedRichText(context, text,
        messagesRegularSkin.regularMessageBodyTextStyle, spanBuilders);
    children.add(highlightedTextWidget);
  }

  if (message.previews != null) {
    message.previews.forEach(
        (preview) => children.add(buildPreview(context, message, preview)));
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

Widget _buildMessageTitle(BuildContext context, ChannelBloc channelBloc,
    RegularMessage message) {
  var iconData = _calculateTitleIconDataForMessage(message);
  var icon = Icon(iconData);

  var startPart;

  if (message.isHaveFromNick) {
    var messageTitleNick =
        _buildMessageTitleNick(context, channelBloc, message);
    startPart = messageTitleNick;
  } else {
    startPart = SizedBox.shrink();
  }

  var endPart;
  var messagesSkin = Provider.of<MessageRegularSkinBloc>(context);
  var color =
      messagesSkin.findTitleColorDataForMessage(message.regularMessageType);

  var messageTitleDate =
      buildMessageTitleDate(context: context, message: message, color: color);
  if (icon != null) {
    endPart = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        messageTitleDate,
        icon,
      ],
    );
  } else {
    endPart = messageTitleDate;
  }

  return buildMessageTitle(startPart, endPart);
}

Widget _buildMessageTitleNick(BuildContext context,
    ChannelBloc channelBloc, RegularMessage message) {
  var nick = message.fromNick;

  return buildUserNickWithPopupMenu(
      context: context, nick: nick, actionCallback: null);
}

Widget _buildTitleSubMessage(BuildContext context, RegularMessage message) {
  var messagesSkin = Provider.of<MessageRegularSkinBloc>(context);

  var regularMessageType = message.regularMessageType;
  var appLocalizations = AppLocalizations.of(context);
  String str;
  switch (regularMessageType) {
    case RegularMessageType.topicSetBy:
      str =
          appLocalizations.tr("chat.message.regular.sub_message.topic_set_by");
      break;
    case RegularMessageType.topic:
      str = appLocalizations.tr("chat.message.regular.sub_message.topic");
      break;
    case RegularMessageType.whoIs:
      str = appLocalizations.tr("chat.message.regular.sub_message.who_is");
      break;
    case RegularMessageType.unhandled:
      str = null;
      break;
    case RegularMessageType.unknown:
      str = appLocalizations.tr("chat.message.regular.sub_message.unknown");
      break;
    case RegularMessageType.message:
      str = null;
      break;
    case RegularMessageType.join:
      str = appLocalizations.tr("chat.message.regular.sub_message.join");
      break;
    case RegularMessageType.mode:
      if (_isHaveLongText(message)) {
        str = appLocalizations.tr("chat.message.regular.sub_message.mode_long");
      } else {
        str = appLocalizations.tr("chat.message.regular.sub_message.mode_short",
            args: [message.text]);
      }

      break;
    case RegularMessageType.motd:
      str = appLocalizations
          .tr("chat.message.regular.sub_message.motd", args: [message.text]);
      break;
    case RegularMessageType.notice:
      str = appLocalizations.tr("chat.message.regular.sub_message.notice");
      break;
    case RegularMessageType.error:
      str = appLocalizations.tr("chat.message.regular.sub_message.error");
      break;
    case RegularMessageType.away:
      str = appLocalizations.tr("chat.message.regular.sub_message.away");
      break;
    case RegularMessageType.back:
      str = appLocalizations.tr("chat.message.regular.sub_message.back");
      break;
    case RegularMessageType.modeChannel:
      str = appLocalizations.tr("chat.message.regular.sub_message.channel_mode",
          args: [message.text]);
      break;
    case RegularMessageType.quit:
      str = appLocalizations.tr("chat.message.regular.sub_message.quit");
      break;
    case RegularMessageType.raw:
      str = null;
      break;
    case RegularMessageType.part:
      str = appLocalizations.tr("chat.message.regular.sub_message.part");
      break;
    case RegularMessageType.nick:
      str = appLocalizations
          .tr("chat.message.regular.sub_message.nick", args: [message.newNick]);
      break;
    case RegularMessageType.ctcpRequest:
      str =
          appLocalizations.tr("chat.message.regular.sub_message.ctcp_request");
      break;
  }

  if (str != null) {
    return Text(str,
        style: messagesSkin.getTextStyleDataForMessage(regularMessageType));
  } else {
    return null;
  }
}



bool _isHaveLongText(RegularMessage message) =>
    message.text != null ? message.text.length >
        _longMessageTextMinimumLength : false;

IconData _calculateTitleIconDataForMessage(RegularMessage message) {
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
      icon = Icons.message;
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
  }
  return icon;
}
