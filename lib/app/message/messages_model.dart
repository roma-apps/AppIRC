abstract class ChatMessage {
  int messageLocalId;

   int channelLocalId;

  final ChatMessageType chatMessageType;

  final int channelRemoteId;

  ChatMessage(this.chatMessageType, this.channelRemoteId);

  bool get isSpecial => chatMessageType == ChatMessageType.SPECIAL;
  bool get isRegular => chatMessageType == ChatMessageType.REGULAR;
}

enum ChatMessageType { SPECIAL, REGULAR }
