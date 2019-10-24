import 'dart:convert';

import 'package:flutter_appirc/app/message/messages_model.dart';

const int chatMessageTypeRegularId = 1;
const int chatMessageTypeSpecialId = 2;

abstract class ChatMessageDB {
  int get channelLocalId;

  int get chatMessageTypeId;

  static ChatMessageType chatMessageType(ChatMessageDB message) =>
      chatMessageTypeIdToType(message.chatMessageTypeId);

  int get channelRemoteId;

  String get linksJsonEncoded;
}



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

List<String> convertLinks(ChatMessageDB messageDB) {
  var decoded = json.decode(messageDB.linksJsonEncoded);
  var list = decoded as List<dynamic>;

  return list.map((listItem) => listItem.toString()).toList();
}
