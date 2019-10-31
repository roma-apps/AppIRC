import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

class CondensedMessageListItem extends MessageListItem {
  final List<ChatMessage> messages;

  CondensedMessageListItem(this.messages);

  bool isCondensed = true;

  @override
  bool isContainsMessageWithRemoteId(int firstUnreadRemoteMessageId) {
    var contains = false;

    for (var message in messages) {
      contains = isHaveMessageRemoteId(message, firstUnreadRemoteMessageId);
      if (contains) {
        break;
      }
    }

    return contains;
  }

  @override
  // messages sorted by date
  RegularMessage get oldestRegularMessage => messages.firstWhere((message) {
        return message is RegularMessage;
      }, orElse: () => null);

  @override
  bool isContainsText(String searchTerm, {bool ignoreCase}) {
    var contains = false;

    for (var message in messages) {
      contains = message.isContainsText(searchTerm, ignoreCase: ignoreCase);
      if (contains) {
        break;
      }
    }

    return contains;
  }
}
