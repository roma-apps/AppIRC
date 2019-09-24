abstract class ChatMessage {
  int messageLocalId;

   int channelLocalId;

  final ChatMessageType chatMessageType;

  final int channelRemoteId;

  ChatMessage(this.chatMessageType, this.channelRemoteId);
}

enum ChatMessageType { SPECIAL, REGULAR }
