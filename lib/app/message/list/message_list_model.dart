import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

class MessageListVisibleBounds {
  MessageListItem min;
  MessageListItem max;

  MessageListVisibleBounds({@required this.min, @required this.max});

  @override
  String toString() {
    return 'VisibleMessagesBounds{min: $min, max: $max}';
  }
}

abstract class MoreHistoryOwner {
  bool get moreHistoryAvailable;

  Stream<bool> get moreHistoryAvailableStream;
}

class SimpleMessageListItem extends MessageListItem {
  final ChatMessage message;
  SimpleMessageListItem(this.message);

  @override
  bool isContainsMessageWithRemoteId(int firstUnreadRemoteMessageId) {
    return isHaveMessageRemoteId(this.message, firstUnreadRemoteMessageId);
  }

  @override
  RegularMessage get oldestRegularMessage =>
      message is RegularMessage ? message : null;

  @override
  bool isContainsText(String searchTerm, {bool ignoreCase}) =>
      message.isContainsText(searchTerm, ignoreCase: ignoreCase);
}

abstract class MessageListItem {
  bool get isHaveRegularMessage => oldestRegularMessage != null;

  RegularMessage get oldestRegularMessage;

  bool isContainsMessageWithRemoteId(int firstUnreadRemoteMessageId);

  bool isContainsText(String searchTerm, {bool ignoreCase});
}

class MessageListState {
  final List<MessageListItem> items;
  final bool moreHistoryAvailable;

  MessageListState.name(
      {@required this.items, @required this.moreHistoryAvailable});

  static get empty =>
      MessageListState.name(items: [], moreHistoryAvailable: false);

  @override
  String toString() {
    return 'ChatMessagesListState{items: $items,'
        ' moreHistoryAvailable: $moreHistoryAvailable}';
  }
}

class MessageListLoadMore {
  List<ChatMessage> messages;
  bool moreHistoryAvailable;
  MessageListLoadMore(this.messages, this.moreHistoryAvailable);

  MessageListLoadMore.name(
      {@required this.messages, @required this.moreHistoryAvailable});
}

bool isHaveMessageRemoteId(ChatMessage message,
    int firstUnreadRemoteMessageId) {
  if (message is RegularMessage) {
    return message.messageRemoteId == firstUnreadRemoteMessageId;
  } else {
    return false;
  }
}
