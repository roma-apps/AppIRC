import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:intl/intl.dart';

var _onlyDateFormatter = new DateFormat().add_yMd();

class DaysDateSeparatorMessageListItemWidget extends StatelessWidget {
  final DaysDateSeparatorMessageListItem item;

  DaysDateSeparatorMessageListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    var date = item.dayFirstDate;

    return _buildDateWidget(context, date);
  }
}

Container _buildDateWidget(BuildContext context, DateTime date) {
  var dateString = _onlyDateFormatter.format(date);
  return buildMessageDateWidget(context, dateString);
}

Container buildMessageDateWidget(BuildContext context, String dateString) {
  MessageSkinBloc messageSkinBloc = Provider.of(context);
  var borderSide = BorderSide(color: Colors.grey);
  return Container(
    decoration: BoxDecoration(border: Border(top: borderSide)),
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        dateString,
        style: messageSkinBloc.messageBodyTextStyle,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
