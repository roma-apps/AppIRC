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

  ChatMessage(this.chatMessageType, this.channelRemoteId, this.date);

  bool get isSpecial => chatMessageType == ChatMessageType.SPECIAL;
  bool get isRegular => chatMessageType == ChatMessageType.REGULAR;
}

enum ChatMessageType { SPECIAL, REGULAR }
