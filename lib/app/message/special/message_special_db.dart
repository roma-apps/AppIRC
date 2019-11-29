import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_db.dart';
import 'package:flutter_appirc/app/message/special/body/channel_info/message_special_channel_info_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/text/message_special_text_body_model.dart';
import 'package:flutter_appirc/app/message/special/body/whois/message_special_who_is_body_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';


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

  @update
  Future<int> updateRegularMessage(SpecialMessageDB specialMessage);

  @Query('DELETE FROM SpecialMessageDB')
  Future<void> deleteAllSpecialMessages();

  @Query(
      'DELETE FROM SpecialMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<void> deleteChannelSpecialMessages(int channelRemoteId);
}

@Entity(tableName: "SpecialMessageDB")
class SpecialMessageDB implements ChatMessageDB {
  @PrimaryKey(autoGenerate: true)
  int localId;

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
      return SpecialMessageType.whoIs;
      break;
    case 2:
      return SpecialMessageType.channelsListItem;
      break;
    case 3:
      return SpecialMessageType.text;
      break;
  }

  throw Exception("Invalid SpecialMessageType id $id");
}

int specialMessageTypeTypeToId(SpecialMessageType type) {
  switch (type) {
    case SpecialMessageType.whoIs:
      return 1;
      break;
    case SpecialMessageType.channelsListItem:
      return 2;
      break;
    case SpecialMessageType.text:
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
    case SpecialMessageType.whoIs:
      body = WhoIsSpecialMessageBody.fromJson(decodedJson);
      break;
    case SpecialMessageType.channelsListItem:
      body = ChannelInfoSpecialMessageBody.fromJson(decodedJson);
      break;
    case SpecialMessageType.text:
      body = TextSpecialMessageBody.fromJson(decodedJson);
      break;
  }

  return SpecialMessage.name(
      messageLocalId: messageDB.localId,
      channelRemoteId: messageDB.channelRemoteId,
      data: body,
      specialType: type,
      linksInMessage: messageDB.linksJsonEncoded != null
          ? convertLinks(messageDB) : null,
      date: DateTime.fromMicrosecondsSinceEpoch(
          messageDB.dateMicrosecondsSinceEpoch));
}
