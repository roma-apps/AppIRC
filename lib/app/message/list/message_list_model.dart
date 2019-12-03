import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

class MessageListVisibleBounds {
  final int minRegularMessageRemoteId;
  final int maxRegularMessageRemoteId;
  final MessageListVisibleBoundsUpdateType updateType;

  MessageListVisibleBounds._name({
    @required this.minRegularMessageRemoteId,
    @required this.maxRegularMessageRemoteId,
    @required this.updateType,
  });

  MessageListVisibleBounds.fromPush({@required int messageRemoteId})
      : this._name(
            minRegularMessageRemoteId: messageRemoteId,
            maxRegularMessageRemoteId: messageRemoteId,
            updateType: MessageListVisibleBoundsUpdateType.push);

  MessageListVisibleBounds.fromUi(
      {@required int minRegularMessageRemoteId,
      @required int maxRegularMessageRemoteId})
      : this._name(
            minRegularMessageRemoteId: minRegularMessageRemoteId,
            maxRegularMessageRemoteId: maxRegularMessageRemoteId,
            updateType: MessageListVisibleBoundsUpdateType.ui);

  @override
  String toString() {
    return 'VisibleMessagesBounds{min: $minRegularMessageRemoteId,'
        ' max: $maxRegularMessageRemoteId}';
  }
}

enum MessageListVisibleBoundsUpdateType { push, ui }

class SimpleMessageListItem extends MessageListItem {
  final ChatMessage message;

  SimpleMessageListItem(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleMessageListItem &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() {
    return 'SimpleMessageListItem{message: $message}';
  }

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
  final List<ChatMessage> newItems;

//  final bool moreHistoryAvailable;
  final MessageListUpdateType updateType;

  MessageListState.name(
      {@required this.items,
      @required this.newItems,
      @required this.updateType});

  static get empty => MessageListState.name(
      items: [], newItems: [], updateType: MessageListUpdateType.notUpdated);

  @override
  String toString() {
    return 'MessageListState{'
        'items: $items,'
        'newItems: $newItems,'
        ' updateType: $updateType'
        '}';
  }
}

class MessageListLoadMore {
  final List<ChatMessage> messages;
  final int totalMessages;

  MessageListLoadMore(this.messages, this.totalMessages);

  MessageListLoadMore.name(
      {@required this.messages, @required this.totalMessages});
}

bool isHaveMessageRemoteId(
    ChatMessage message, int firstUnreadRemoteMessageId) {
  if (message is RegularMessage) {
    return message.messageRemoteId == firstUnreadRemoteMessageId;
  } else {
    return false;
  }
}

class MessageListJumpDestination {
  final List<MessageListItem> items;
  final MessageListItem selectedFoundItem;
  final double alignment;

  MessageListJumpDestination(
      {@required this.items,
      @required this.selectedFoundItem,
      @required this.alignment});
}
