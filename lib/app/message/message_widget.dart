import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_widget.dart';
import 'package:flutter_appirc/app/user/user_widget.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:intl/intl.dart';

var todayDateFormatter = new DateFormat().add_Hm();
var regularDateFormatter = new DateFormat().add_yMd().add_Hm();

//Widget buildMessageTitle(startPart, endPart) {
//  if (startPart != null && endPart != null) {
//    return Row(
//        children: <Widget>[startPart, endPart],
//        mainAxisAlignment: MainAxisAlignment.spaceBetween);
//  } else {
//    if (startPart != null) {
//      return Align(child: startPart, alignment: Alignment.centerLeft);
//    } else if (endPart != null) {
//      return Align(child: endPart, alignment: Alignment.centerRight);
//    } else {
//      return Container();
//    }
//  }
//}

Widget buildMessage(BuildContext context, DateTime date, IconData iconData,
    Color color, String nick, String title, List<InlineSpan> bodySpans) {
  var messagesSkin = Provider.of<MessageSkinBloc>(context);
  var coloredNicknamesSkin = Provider.of<ColoredNicknamesBloc>(context);
  var dateString;

  if (isToday(date)) {
    dateString = todayDateFormatter.format(date);
  } else {
    dateString = regularDateFormatter.format(date);
  }

  var children = <InlineSpan>[];

  children.add(TextSpan(
    text: dateString,
    style: messagesSkin.createDateTextStyle(color),
  ));

  if (iconData != null) {
    children.add(WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Icon(
          iconData,
          size: 16,
          color: color,
        ),
      ),
    ));
  }

  if (nick?.isNotEmpty == true) {
    children.add(WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: buildUserNickWithPopupMenu(
            context: context, nick: nick, actionCallback: null),
      ),
    ));
  }

  if (title?.isNotEmpty == true) {
    children.add(TextSpan(
      text: "$title ",
      style: messagesSkin.createMessageSubTitleTextStyle(color),
    ));
  }

  if (bodySpans?.isNotEmpty == true) {
    children.addAll(bodySpans);
  }

//  if (text?.isNotEmpty == true) {
//    children.add(TextSpan(
//      text: text,
//      style: messagesRegularSkin.regularMessageBodyTextStyle,
//    ));
//  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: RichText(
      text: TextSpan(
        children: children,
      ),
    ),
  );
}

//Widget buildMessageTitleDate(
//    {@required BuildContext context,
//    @required ChatMessage message,
//    @required Color color}) {
//  var messagesSkin = Provider.of<MessageSkinBloc>(context);
//
//  return Padding(
//    padding: const EdgeInsets.all(4.0),
//    child: Text(
//      dateString,
//      style: messagesSkin.createDateTextStyle(color),
//    ),
//  );
//}

//Widget buildMessageWidget(
//    {@required BuildContext context,
//    @required Widget title,
//    @required Widget body,
//    @required Color color}) {
//  return Padding(
//    padding: const EdgeInsets.all(4.0),
//    child: Column(
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.all(2.0),
//          child: title,
//        ),
//        Padding(
//          padding: const EdgeInsets.symmetric(horizontal: 2.0),
//          child: body,
//        ),
//      ],
//    ),
//  );
//}

Widget buildMessageBody(BuildContext context, ChatMessage message,
    bool inSearchResults, String searchTerm) {
  Widget messageBody;

  var chatMessageType = message.chatMessageType;

  switch (chatMessageType) {
    case ChatMessageType.special:
      var specialMessage = message as SpecialMessage;
      messageBody = buildSpecialMessageWidget(
          context, specialMessage, inSearchResults, searchTerm);
      break;
    case ChatMessageType.regular:
      messageBody =
          buildRegularMessage(context, message, inSearchResults, searchTerm);
      break;
  }

  if (messageBody == null) {
    throw Exception("Invalid message type = $chatMessageType");
  }
  return messageBody;
}

Container buildMessageItem(BuildContext context, ChatMessage message,
    bool inSearchResults, String searchTerm) {
  var messageBody =
      buildMessageBody(context, message, inSearchResults, searchTerm);
  var decoration = _createMessageDecoration(context, message, inSearchResults);
  return Container(decoration: decoration, child: messageBody);
}

isNeedHighlight(RegularMessage message) =>
    message.highlight == true ||
    message.regularMessageType == RegularMessageType.unknown;

_createMessageDecoration(
    BuildContext context, ChatMessage message, bool isHighlightBySearch) {
  var decoration;
  bool isHighlightByServer;

  if (message is RegularMessage) {
    isHighlightByServer = isNeedHighlight(message);
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
