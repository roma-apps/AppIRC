import 'package:flutter/widgets.dart';

abstract class ChatMessage {
  int messageLocalId;

  int channelLocalId;

  final ChatMessageType chatMessageType;

  final int channelRemoteId;
  final DateTime date;
  final List<String> linksInText;

  bool get isMessageDateToday {
    var now = DateTime.now();
    var todayStart = now.subtract(
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
    return todayStart.isBefore(date);
  }

  ChatMessage(
      this.chatMessageType, this.channelRemoteId, this.date, this.linksInText,
      {this.messageLocalId});

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
}

bool isContainsSearchTerm(String text, String searchTerm, {bool ignoreCase}) {
  if(text == null) {
    return false;
  }
  if(ignoreCase == true) {
    return text.toLowerCase().contains(searchTerm.toLowerCase());
  } else {
    return text.contains(searchTerm);
  }
}

enum ChatMessageType { special, regular }


class MessageListState {
  final List<ChatMessage> messages;
  final bool moreHistoryAvailable;

  MessageListState.name(
      {@required this.messages, @required this.moreHistoryAvailable});

  static get empty =>
      MessageListState.name(messages: [], moreHistoryAvailable: false);

  @override
  String toString() {
    return 'ChatMessagesListState{messages: $messages,'
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
