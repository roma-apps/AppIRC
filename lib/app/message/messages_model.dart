abstract class ChatMessage {
  int messageLocalId;

  int channelLocalId;

  final ChatMessageType chatMessageType;

  final int channelRemoteId;
  final DateTime date;

  bool get isMessageDateToday {
    var now = DateTime.now();
    var todayStart = now.subtract(
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
    return todayStart.isBefore(date);
  }

  ChatMessage(this.chatMessageType, this.channelRemoteId, this.date, {this.messageLocalId});

  bool get isSpecial => chatMessageType == ChatMessageType.SPECIAL;

  bool get isRegular => chatMessageType == ChatMessageType.REGULAR;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          messageLocalId == other.messageLocalId;
  @override
  int get hashCode => messageLocalId.hashCode;
}

enum ChatMessageType { SPECIAL, REGULAR }
