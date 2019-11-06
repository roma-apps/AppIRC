import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

class DaysDateSeparatorMessageListItem extends MessageListItem {
  final DateTime dayFirstDate;
  DaysDateSeparatorMessageListItem(this.dayFirstDate);


  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DaysDateSeparatorMessageListItem &&
          runtimeType == other.runtimeType &&
          dayFirstDate == other.dayFirstDate;
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
