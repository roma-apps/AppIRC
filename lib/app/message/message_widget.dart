import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:intl/intl.dart';

var todayDateFormatter = new DateFormat().add_Hm();
var regularDateFormatter = new DateFormat().add_yMd().add_Hm();

Widget buildMessageTitle(startPart, endPart) {
  if (startPart != null && endPart != null) {
    return Row(
        children: <Widget>[startPart, endPart],
        mainAxisAlignment: MainAxisAlignment.spaceBetween);
  } else {
    if (startPart != null) {
      return Align(child: startPart, alignment: Alignment.centerLeft);
    } else if (endPart != null) {
      return Align(child: endPart, alignment: Alignment.centerRight);
    } else {
      return Container();
    }
  }
}

Widget buildMessageTitleDate(
    {@required BuildContext context,
    @required ChatMessage message,
    @required Color color}) {
  var messagesSkin = Provider.of<MessageSkinBloc>(context);

  var dateString;

  var date = message.date;

  if (message.isMessageDateToday) {
    dateString = todayDateFormatter.format(date);
  } else {
    dateString = regularDateFormatter.format(date);
  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Text(
      dateString,
      style: messagesSkin.createDateTextStyle(color),
    ),
  );
}

Widget buildMessageWidget(
    {@required BuildContext context,
    @required Widget title,
    @required Widget body,
    @required Color color}) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: title,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: body,
        ),
      ],
    ),
  );
}
