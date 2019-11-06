import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:intl/intl.dart';

var _onlyDateFormatter = new DateFormat().add_yMd();

class DaysDateSeparatorMessageListItemWidget extends StatelessWidget {
  final DaysDateSeparatorMessageListItem item;
  DaysDateSeparatorMessageListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    var borderSide = BorderSide(color: Colors.grey);
    return Container(
      decoration: BoxDecoration(border: Border(top: borderSide)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          _onlyDateFormatter.format(item.dayFirstDate),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
