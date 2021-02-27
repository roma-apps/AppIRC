import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:intl/intl.dart';

var _onlyDateFormatter = DateFormat().add_yMd();

class DaysDateSeparatorMessageListItemWidget extends StatelessWidget {
  final DaysDateSeparatorMessageListItem item;

  DaysDateSeparatorMessageListItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    var date = item.dayFirstDate;

    return _buildDateWidget(context, date);
  }
}

Container _buildDateWidget(
  BuildContext context,
  DateTime date,
) {
  var dateString = _onlyDateFormatter.format(date);
  return buildMessageDateWidget(context, dateString);
}

Container buildMessageDateWidget(
  BuildContext context,
  String dateString,
) {
  var borderSide = BorderSide(color: Colors.grey);
  return Container(
    decoration: BoxDecoration(border: Border(top: borderSide)),
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        dateString,
        style: IAppIrcUiTextTheme.of(context)
            .mediumDarkGrey
            .copyWith(fontFamily: messagesFontFamily),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
