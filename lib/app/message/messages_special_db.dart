import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_db.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_db.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';


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

  @Query(
      'DELETE FROM SpecialMessageDB WHERE channelRemoteId = :channelRemoteId')
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

  final int dateMicrosecondsSinceEpoch;
  final String linksJsonEncoded;

  static DateTime date(SpecialMessageDB message) =>
      DateTime.fromMicrosecondsSinceEpoch(message.dateMicrosecondsSinceEpoch);

  SpecialMessageDB(
      this.localId,
      this.channelLocalId,
      this.chatMessageTypeId,
      this.channelRemoteId,
      this.dataJsonEncoded,
      this.specialTypeId,
      this.dateMicrosecondsSinceEpoch,
      this.linksJsonEncoded
      );

  SpecialMessageDB.name(
      {this.localId,
      this.channelLocalId,
      this.chatMessageTypeId = chatMessageTypeSpecialId,
      @required this.channelRemoteId,
      @required this.dataJsonEncoded,
      @required this.specialTypeId,
      @required this.dateMicrosecondsSinceEpoch,
      @required this.linksJsonEncoded
      });
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
        specialTypeId: specialMessageTypeTypeToId(specialMessage.specialType),
        linksJsonEncoded: specialMessage.linksInText != null
            ? json.encode(specialMessage.linksInText)
            : null,
        dateMicrosecondsSinceEpoch: specialMessage.date.microsecondsSinceEpoch);



SpecialMessage specialMessageDBToChatMessage(SpecialMessageDB messageDB) {
  var type = specialMessageTypeIdToType(messageDB.specialTypeId);
  var decodedJson = json.decode(messageDB.dataJsonEncoded);
  var body;
  switch (type) {
    case SpecialMessageType.WHO_IS:
      body = WhoIsSpecialMessageBody.fromJson(decodedJson);
      break;
    case SpecialMessageType.CHANNELS_LIST_ITEM:
      body = NetworkChannelInfoSpecialMessageBody.fromJson(decodedJson);
      break;
    case SpecialMessageType.TEXT:
      body = TextSpecialMessageBody.fromJson(decodedJson);
      break;
  }

  return SpecialMessage.name(
      messageLocalId: messageDB.localId,
      channelRemoteId: messageDB.channelRemoteId,
      data: body,
      specialType: type,
      linksInText: messageDB.linksJsonEncoded != null
          ? convertLinks(messageDB) : null,
      date: DateTime.fromMicrosecondsSinceEpoch(
          messageDB.dateMicrosecondsSinceEpoch));
}
