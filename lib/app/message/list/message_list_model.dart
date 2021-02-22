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
          updateType: MessageListVisibleBoundsUpdateType.push,
        );

  MessageListVisibleBounds.fromUi(
      {@required int minRegularMessageRemoteId,
      @required int maxRegularMessageRemoteId})
      : this._name(
          minRegularMessageRemoteId: minRegularMessageRemoteId,
          maxRegularMessageRemoteId: maxRegularMessageRemoteId,
          updateType: MessageListVisibleBoundsUpdateType.ui,
        );

  @override
  String toString() => 'VisibleMessagesBounds{'
      'min: $minRegularMessageRemoteId, '
      'max: $maxRegularMessageRemoteId'
      '}';
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
    return isHaveMessageRemoteId(message, firstUnreadRemoteMessageId);
  }

  @override
  RegularMessage get oldestRegularMessage =>
      message is RegularMessage ? message : null;

  @override
  bool isContainsText(
    String searchTerm, {
    @required bool ignoreCase,
  }) =>
      message.isContainsText(searchTerm, ignoreCase: ignoreCase);
}

abstract class MessageListItem {
  bool get isHaveRegularMessage => oldestRegularMessage != null;

  RegularMessage get oldestRegularMessage;

  bool isContainsMessageWithRemoteId(int firstUnreadRemoteMessageId);

  bool isContainsText(
    String searchTerm, {
    @required bool ignoreCase,
  });
}

class MessageListState {
  final List<MessageListItem> items;
  final List<ChatMessage> newItems;
  final MessageListUpdateType updateType;

  MessageListState.name({
    @required this.items,
    @required this.newItems,
    @required this.updateType,
  });

  static MessageListState get empty => MessageListState.name(
        items: [],
        newItems: [],
        updateType: MessageListUpdateType.notUpdated,
      );

  @override
  String toString() {
    return 'MessageListState{'
        'items: $items,'
        'newItems: $newItems, '
        'updateType: $updateType'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageListState &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          newItems == other.newItems &&
          updateType == other.updateType;

  @override
  int get hashCode => items.hashCode ^ newItems.hashCode ^ updateType.hashCode;
}

class MessageListLoadMore {
  final List<ChatMessage> messages;
  final int totalMessages;

  MessageListLoadMore({
    @required this.messages,
    @required this.totalMessages,
  });

  @override
  String toString() {
    return 'MessageListLoadMore{'
        'messages: $messages, '
        'totalMessages: $totalMessages'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageListLoadMore &&
          runtimeType == other.runtimeType &&
          messages == other.messages &&
          totalMessages == other.totalMessages;

  @override
  int get hashCode => messages.hashCode ^ totalMessages.hashCode;
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

  MessageListJumpDestination({
    @required this.items,
    @required this.selectedFoundItem,
    @required this.alignment,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageListJumpDestination &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          selectedFoundItem == other.selectedFoundItem &&
          alignment == other.alignment;

  @override
  int get hashCode =>
      items.hashCode ^ selectedFoundItem.hashCode ^ alignment.hashCode;

  @override
  String toString() => 'MessageListJumpDestination{'
        'items: $items, '
        'selectedFoundItem: $selectedFoundItem, '
        'alignment: $alignment'
        '}';
}
