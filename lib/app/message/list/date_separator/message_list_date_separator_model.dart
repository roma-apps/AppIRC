import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

class DaysDateSeparatorMessageListItem extends MessageListItem {
  final DateTime dayFirstDate;
  DaysDateSeparatorMessageListItem(this.dayFirstDate);

  @override
  RegularMessage get oldestRegularMessage => null;

  @override
  bool isContainsText(String searchTerm, {bool ignoreCase}) => false;

  @override
  bool isContainsMessageWithRemoteId(int firstUnreadRemoteMessageId) => false;
}
