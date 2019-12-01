import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/message/special/body/channel_info/message_special_channel_info_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/channel_info/message_special_channel_info_body_widget.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_widget.dart';
import 'package:flutter_appirc/app/message/special/body/text/message_special_text_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/text/message_special_text_body_widget.dart';
import 'package:flutter_appirc/app/message/special/body/whois/message_special_who_is_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/whois/message_special_who_is_body_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';

class SpecialMessageWidget extends MessageWidget<SpecialMessage> {
  SpecialMessageWidget(
      {@required SpecialMessage message,
      @required MessageInListState messageInListState,
      @required bool enableMessageActions,
      @required MessageWidgetType messageWidgetType})
      : super(
            message: message,
            messageInListState: messageInListState,
            enableMessageActions: enableMessageActions,
            messageWidgetType: messageWidgetType);

  @override
  Widget buildMessageBody(BuildContext context, ChatMessage message) {
    switch (messageWidgetType) {
      case MessageWidgetType.formatted:
        return _buildSpecialBody(messageInListState.inSearchResult);
        break;
      case MessageWidgetType.raw:
        return buildMessageRawBody(context, message, getBodyRawText(context));
        break;

      default:
        throw "Invalud message widget type $messageWidgetType";
    }
  }

  @override
  String getBodyRawText(BuildContext context) {
    return _buildSpecialBody(false).getBodyRawText(context);
  }

  SpecialMessageBodyWidget _buildSpecialBody(bool inSearchResults) {
    SpecialMessageBodyWidget messageBodyWidget;
    switch (message.specialType) {
      case SpecialMessageType.whoIs:
        messageBodyWidget = WhoIsSpecialMessageBodyWidget(
          message: message,
          inSearchResults: inSearchResults,
          body: message.data as WhoIsSpecialMessageBody,
          messageWidgetType: messageWidgetType,
        );
        break;
      case SpecialMessageType.channelsListItem:
        messageBodyWidget = ChannelInfoSpecialMessageBodyWidget(
          message: message,
          inSearchResults: inSearchResults,
          body: message.data as ChannelInfoSpecialMessageBody,
          messageWidgetType: messageWidgetType,
          messageInListState: messageInListState,
        );
        break;
      case SpecialMessageType.text:
        messageBodyWidget = TextSpecialMessageBodyWidget(
          message: message,
          inSearchResults: inSearchResults,
          body: message.data as TextSpecialMessageBody,
          messageWidgetType: messageWidgetType,
        );
        break;
      default:
        throw Exception("Invalid message type $message");
    }

    return messageBodyWidget;
  }
}
