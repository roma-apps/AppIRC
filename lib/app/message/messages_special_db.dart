import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_db.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';

//part 'messages_special_db_dao.g.dart';

@dao
abstract class SpecialMessageDao {
  @Query('SELECT * FROM SpecialMessageDB')
  Future<List<SpecialMessageDB>> getAllMessages();

  @Query(
      'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<List<SpecialMessageDB>> getChannelMessages(int channelRemoteId);

  @Query(
      'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = :channelRemoteId')
  Stream<List<SpecialMessageDB>> getChannelMessagesStream(int channelRemoteId);

  @insert
  Future<int> insertSpecialMessage(SpecialMessageDB specialMessage);

  @Query('DELETE FROM SpecialMessageDB')
  Future<void> deleteAllSpecialMessages();

  @Query('DELETE FROM SpecialMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<void> deleteChannelSpecialMessages(int channelRemoteId);
}

@Entity(tableName: "SpecialMessageDB")
class SpecialMessageDB implements ChatMessageDB {
  @PrimaryKey(autoGenerate: true)
  final int localId;

  int channelLocalId;

  final int chatMessageTypeId;

  final int channelRemoteId;

  final String dataJsonEncoded;
  int specialTypeId;

  SpecialMessageDB(this.localId, this.channelLocalId, this.chatMessageTypeId,
      this.channelRemoteId, this.dataJsonEncoded, this.specialTypeId);

  SpecialMessageDB.name(
      {this.localId,
      this.channelLocalId,
      this.chatMessageTypeId = chatMessageTypeSpecialId,
      @required this.channelRemoteId,
      @required this.dataJsonEncoded,
      @required this.specialTypeId});
}

SpecialMessageType specialMessageTypeIdToType(int id) {
  switch (id) {
    case 1:
      return SpecialMessageType.WHO_IS;
      break;
    case 2:
      return SpecialMessageType.CHANNELS_LIST_ITEM;
      break;
    case 3:
      return SpecialMessageType.TEXT;
      break;
  }

  throw Exception("Invalid SpecialMessageType id $id");
}

int specialMessageTypeTypeToId(SpecialMessageType type) {
  switch (type) {
    case SpecialMessageType.WHO_IS:
      return 1;
      break;
    case SpecialMessageType.CHANNELS_LIST_ITEM:
      return 2;
      break;
    case SpecialMessageType.TEXT:
      return 3;
      break;
  }
  throw Exception("Invalid SpecialMessageType = $type");
}

SpecialMessageDB toSpecialMessageDB(SpecialMessage specialMessage) =>
    SpecialMessageDB.name(
        channelRemoteId: specialMessage.channelRemoteId,
        dataJsonEncoded: json.encode(specialMessage.data),
        specialTypeId: specialMessageTypeTypeToId(specialMessage.specialType));
