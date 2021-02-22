import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';

abstract class ChatMessage {
  int messageLocalId;

  int channelLocalId;

  final ChatMessageType chatMessageType;

  final int channelRemoteId;
  final DateTime date;
  List<String> linksInText;

  ChatMessage(
    this.chatMessageType,
    this.channelRemoteId,
    this.date,
    this.linksInText, {
    this.messageLocalId,
  });

  bool get isSpecial => chatMessageType == ChatMessageType.special;

  bool get isRegular => chatMessageType == ChatMessageType.regular;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          messageLocalId == other.messageLocalId;

  @override
  int get hashCode => messageLocalId.hashCode;

  bool isContainsText(String searchTerm, {@required bool ignoreCase});

  Future<List<String>> extractLinks();
}

bool isContainsSearchTerm(String text, String searchTerm, {bool ignoreCase}) {
  if (text == null) {
    return false;
  }
  if (ignoreCase == true) {
    return text.toLowerCase().contains(searchTerm.toLowerCase());
  } else {
    return text.contains(searchTerm);
  }
}

enum ChatMessageType { special, regular }

class MessagesForChannel {
  final Channel channel;
  List<ChatMessage> messages;
  final bool isNeedCheckAdditionalLoadMore;
  final bool isNeedCheckAlreadyExistInLocalStorage;
  final bool isContainsTextSpecialMessage;

  MessagesForChannel.name({
    @required this.channel,
    @required this.messages,
    @required this.isNeedCheckAlreadyExistInLocalStorage,
    @required this.isNeedCheckAdditionalLoadMore,
    this.isContainsTextSpecialMessage = false,
  });

  @override
  String toString() {
    return 'MessagesForChannel{channel: $channel,'
        ' messages: $messages, '
        ' isNeedCheckAlreadyExistInLocalStorage: $isNeedCheckAlreadyExistInLocalStorage, '
        ' isNeedCheckAdditionalLoadMore: $isNeedCheckAdditionalLoadMore, '
        'isContainsTextSpecialMessage: $isContainsTextSpecialMessage'
        '}';
  }
}

class MessagesList {
  List<ChatMessage> allMessages;
  List<ChatMessage> lastAddedMessages;
  MessageListUpdateType messageListUpdateType;

  MessagesList({
    @required this.allMessages,
    @required this.lastAddedMessages,
    @required this.messageListUpdateType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesList &&
          runtimeType == other.runtimeType &&
          allMessages == other.allMessages &&
          lastAddedMessages == other.lastAddedMessages &&
          messageListUpdateType == other.messageListUpdateType;

  @override
  int get hashCode =>
      allMessages.hashCode ^
      lastAddedMessages.hashCode ^
      messageListUpdateType.hashCode;

  @override
  String toString() => 'MessagesList{'
      'allMessages: $allMessages, '
      'lastAddedMessages: $lastAddedMessages, '
      'messageListUpdateType: $messageListUpdateType'
      '}';
}

enum MessageListUpdateType {
  loadedFromLocalDatabase,
  newMessagesFromBackend,
  historyFromBackend,
  notUpdated
}

class MessageInListState {
  final bool inSearchResult;
  final String searchTerm;

  MessageInListState.name({
    @required this.inSearchResult,
    @required this.searchTerm,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageInListState &&
          runtimeType == other.runtimeType &&
          inSearchResult == other.inSearchResult &&
          searchTerm == other.searchTerm;

  @override
  int get hashCode => inSearchResult.hashCode ^ searchTerm.hashCode;

  @override
  String toString() => 'MessageInListState{'
        'inSearchResult: $inSearchResult, '
        'searchTerm: $searchTerm}';
}
