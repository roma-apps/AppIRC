import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';

abstract class ChatMessage {
  int messageLocalId;

  int channelLocalId;

  final ChatMessageType chatMessageType;

  final int channelRemoteId;
  final DateTime date;
  final List<String> linksInText;

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
  final List<ChatMessage> messages;
  final bool isContainsTextSpecialMessage;

  MessagesForChannel.name(
      {@required this.channel,
      @required this.messages,
      this.isContainsTextSpecialMessage = false});

  @override
  String toString() {
    return 'MessagesForChannel{channel: $channel, messages: $messages, '
        'isContainsTextSpecialMessage: $isContainsTextSpecialMessage}';
  }
}
