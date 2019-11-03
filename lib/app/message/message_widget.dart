import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_widget.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:intl/intl.dart';

var todayDateFormatter = new DateFormat().add_Hm();
var regularDateFormatter = new DateFormat().add_yMd().add_Hm();

//Widget buildMessageMainPartWidget(
//    {@required BuildContext context,
//    @required DateTime date,
//    @required IconData iconData,
//    @required Color color,
//    @required String nick,
//    @required String title,
//    @required List<InlineSpan> bodySpans}) {
//  var spans = <InlineSpan>[];
//  spans.add(
//      buildMessageDateTextSpan(context: context, date: date, color: color));
//
//  if (iconData != null) {
//    spans.add(buildMessageIconWidgetSpan(iconData: iconData, color: color));
//  }
//
//  if (nick?.isNotEmpty == true) {
//    spans.add(
//        buildHighlightedNicknameButtonWidgetSpan(context: context, nick: nick));
//  }
//
//  if (title?.isNotEmpty == true) {
//    spans.add(buildMessageTitleTextSpan(
//        context: context, title: title, color: color));
//  }
//
//  if (bodySpans?.isNotEmpty == true) {
//    spans.addAll(bodySpans);
//  }
//  return RichText(
//    text: TextSpan(
//      children: spans,
//    ),
//  );
//}

WidgetSpan buildHighlightedNicknameButtonWidgetSpan(
    {@required BuildContext context, @required String nick}) {
  return WidgetSpan(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: buildUserNickWithPopupMenu(
          context: context, nick: nick, actionCallback: null),
    ),
  );
}

WidgetSpan buildMessageIconWidgetSpan(
    {@required IconData iconData, @required Color color}) {
  return WidgetSpan(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(
        iconData,
        size: 16,
        color: color,
      ),
    ),
  );
}

TextSpan buildMessageDateTextSpan(
    {@required BuildContext context,
    @required DateTime date,
    @required Color color}) {
  var messagesSkin = Provider.of<MessageSkinBloc>(context);
  var dateString;

  if (isToday(date)) {
    dateString = todayDateFormatter.format(date);
  } else {
    dateString = regularDateFormatter.format(date);
  }

  var dateTextSpan = TextSpan(
    text: dateString,
    style: messagesSkin.createDateTextStyle(color),
  );
  return dateTextSpan;
}

Widget _buildMessageWidget(
    {@required BuildContext context,
    @required ChatMessage message,
    @required bool inSearchResults,
    @required String searchTerm}) {
  Widget messageBody;

  var chatMessageType = message.chatMessageType;

  switch (chatMessageType) {
    case ChatMessageType.special:
      var specialMessage = message as SpecialMessage;
      messageBody = buildSpecialMessageWidget(
          context: context,
          message: specialMessage,
          includedInSearch: inSearchResults,
          searchTerm: searchTerm);
      break;
    case ChatMessageType.regular:
      messageBody = buildRegularMessageWidget(
          context: context,
          message: message,
          isHighlightedBySearch: inSearchResults,
          searchTerm: searchTerm);
      break;
  }

  if (messageBody == null) {
    throw Exception("Invalid message type = $chatMessageType");
  }
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: messageBody,
  );
}

Container buildDecoratedMessageWidget(
        {@required BuildContext context,
        @required ChatMessage message,
        @required bool inSearchResults,
        @required String searchTerm}) =>
    Container(
        decoration: _createMessageDecoration(
            context: context,
            message: message,
            isHighlightBySearch: inSearchResults),
        child: _buildMessageWidget(
            context: context,
            message: message,
            inSearchResults: inSearchResults,
            searchTerm: searchTerm));

_createMessageDecoration(
    {@required BuildContext context,
    @required ChatMessage message,
    @required bool isHighlightBySearch}) {
  var decoration;
  bool isHighlightByServer;

  if (message is RegularMessage) {
    isHighlightByServer = isHighlightedByServer(message);
  }

  var messagesSkin = Provider.of<MessageListSkinBloc>(context);
  if (isHighlightBySearch) {
    decoration = messagesSkin.highlightSearchDecoration;
  } else {
    if (isHighlightByServer ??= false) {
      decoration = messagesSkin.highlightServerDecoration;
    }
  }
  return decoration;
}
