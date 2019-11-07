import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

class DaysDateSeparatorMessageListItem extends MessageListItem {
  final DateTime dayFirstDate;
  DateTime _dayStartDate;
  DaysDateSeparatorMessageListItem(this.dayFirstDate) {
    _dayStartDate =
        DateTime(dayFirstDate.year, dayFirstDate.month, dayFirstDate.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DaysDateSeparatorMessageListItem &&
          runtimeType == other.runtimeType &&
          _dayStartDate == other._dayStartDate;
  @override
  int get hashCode => dayFirstDate.hashCode;

  @override
  String toString() {
    return 'DaysDateSeparatorMessageListItem{dayFirstDate: $dayFirstDate}';
  }

  @override
  RegularMessage get oldestRegularMessage => null;

  @override
  bool isContainsText(String searchTerm, {bool ignoreCase}) => false;

  @override
  bool isContainsMessageWithRemoteId(int firstUnreadRemoteMessageId) => false;
}
