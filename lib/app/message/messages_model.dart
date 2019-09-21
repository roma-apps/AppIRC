
const int chatMessageTypeRegularId = 1;
const int chatMessageTypeSpecialId = 2;

abstract class ChatMessage {
  int get channelLocalId;

  int get chatMessageTypeId;

  static ChatMessageType chatMessageType(ChatMessage message) =>
      chatMessageTypeIdToType(message.chatMessageTypeId);

  int get channelRemoteId;
}

enum ChatMessageType { SPECIAL, REGULAR }

ChatMessageType chatMessageTypeIdToType(int id) {
  switch (id) {
    case chatMessageTypeRegularId:
      return ChatMessageType.REGULAR;
      break;
    case chatMessageTypeSpecialId:
      return ChatMessageType.SPECIAL;
      break;
  }

  throw Exception("Invalid ChatMessageType id $id");
}

int chatMessageTypeTypeToId(ChatMessageType type) {
  switch (type) {
    case ChatMessageType.REGULAR:
      return chatMessageTypeRegularId;
      break;
    case ChatMessageType.SPECIAL:
      return chatMessageTypeSpecialId;
      break;
  }
  throw Exception("Invalid ChatMessageType = $type");
}
