import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_db.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';

//part 'messages_regular_db_dao.g.dart';

@dao
abstract class RegularMessageDao {
  @Query('SELECT * FROM RegularMessageDB')
  Future<List<RegularMessageDB>> getAllMessages();

  @Query(
      'SELECT * FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<List<RegularMessageDB>> getChannelMessages(int channelRemoteId);

  @Query(
      'SELECT * FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId')
  Stream<List<RegularMessageDB>> getChannelMessagesStream(int channelRemoteId);

  @insert
  Future<int> insertRegularMessage(RegularMessageDB specialMessage);

  @Query('DELETE FROM RegularMessageDB')
  Future<void> deleteAllRegularMessages();

  @Query('DELETE FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<void> deleteChannelRegularMessages(int channelRemoteId);
}

@Entity(tableName: "RegularMessageDB")
class RegularMessageDB implements ChatMessageDB {
  @PrimaryKey(autoGenerate: true)
  final int localId;

  int channelLocalId;

  final int chatMessageTypeId;

  final int channelRemoteId;

  final String command;

  final String hostMask;

  final String text;

  final String paramsJsonEncoded;

  static List<String> params(RegularMessageDB message) =>
      json.decode(message.paramsJsonEncoded);

  final int regularMessageTypeId;

  static RegularMessageType regularMessageType(RegularMessageDB message) =>
      regularMessageTypeIdToType(message.regularMessageTypeId);

  // TODO: Replace with bool when SQFLite Floor ORM will support null for bool types
  final int self;

  static bool isSelf(RegularMessageDB message) =>
      message.self != null ? message.self != 0 : null;

  final int highlight;

  static bool isHighlight(RegularMessageDB message) =>
      message.highlight != null ? message.highlight != 0 : null;

  final String previewsJsonEncoded;

  static List<MessagePreview> previews(RegularMessageDB message) =>
      json.decode(message.previewsJsonEncoded);

  final int dateMicrosecondsSinceEpoch;

  static DateTime date(RegularMessageDB message) =>
      DateTime.fromMicrosecondsSinceEpoch(message.dateMicrosecondsSinceEpoch);

  final int fromRemoteId;

  final String fromNick;

  final String fromMode;
  final String newNick;

  RegularMessageDB(
      this.localId,
      this.channelLocalId,
      this.chatMessageTypeId,
      this.channelRemoteId,
      this.command,
      this.hostMask,
      this.text,
      this.paramsJsonEncoded,
      this.regularMessageTypeId,
      this.self,
      this.highlight,
      this.previewsJsonEncoded,
      this.dateMicrosecondsSinceEpoch,
      this.fromRemoteId,
      this.fromNick,
      this.fromMode,
      this.newNick);

  RegularMessageDB.name(
      {this.localId,
      this.channelLocalId,
      this.chatMessageTypeId = chatMessageTypeRegularId,
      @required this.channelRemoteId,
      this.command,
      this.hostMask,
      this.text,
      this.paramsJsonEncoded,
      this.regularMessageTypeId,
      this.self,
      this.highlight,
      this.previewsJsonEncoded,
      this.dateMicrosecondsSinceEpoch,
      this.fromRemoteId,
      this.fromNick,
      this.fromMode,
      this.newNick
      });

  @override
  String toString() {
    return 'RegularMessageDB{localId: $localId, channelLocalId: $channelLocalId, '
        'chatMessageTypeId: $chatMessageTypeId, channelRemoteId: $channelRemoteId, '
        'command: $command, hostMask: $hostMask, text: $text, '
        'paramsJsonEncoded: $paramsJsonEncoded, '
        'regularMessageTypeId: $regularMessageTypeId,'
        ' self: $self, highlight: $highlight, '
        'previewsJsonEncoded: $previewsJsonEncoded, '
        'dateMicrosecondsSinceEpoch: $dateMicrosecondsSinceEpoch, '
        'fromRemoteId: $fromRemoteId, fromNick: $fromNick, '
        'fromMode: $fromMode, newNick: $newNick}';
  } //  RegularMessage(


}

RegularMessageType regularMessageTypeIdToType(int id) {
  switch (id) {
    case 1:
      return RegularMessageType.TOPIC_SET_BY;
      break;
    case 2:
      return RegularMessageType.TOPIC;
      break;
    case 3:
      return RegularMessageType.WHO_IS;
      break;
    case 4:
      return RegularMessageType.UNHANDLED;
      break;
    case 5:
      return RegularMessageType.UNKNOWN;
      break;
    case 6:
      return RegularMessageType.MESSAGE;
      break;
    case 7:
      return RegularMessageType.JOIN;
      break;
    case 8:
      return RegularMessageType.MODE;
      break;
    case 9:
      return RegularMessageType.MOTD;
      break;
    case 10:
      return RegularMessageType.NOTICE;
      break;
    case 11:
      return RegularMessageType.ERROR;
      break;
    case 12:
      return RegularMessageType.AWAY;
      break;
    case 13:
      return RegularMessageType.BACK;
      break;
    case 14:
      return RegularMessageType.RAW;
      break;
    case 15:
      return RegularMessageType.MODE_CHANNEL;
      break;
    case 16:
      return RegularMessageType.QUIT;
      break;
    case 17:
      return RegularMessageType.PART;
      break;
    case 18:
      return RegularMessageType.NICK;
      break;
  }

  throw Exception("Invalid RegularMessageType id $id");
}

int regularMessageTypeTypeToId(RegularMessageType type) {
  switch (type) {
    case RegularMessageType.TOPIC_SET_BY:
      return 1;
      break;
    case RegularMessageType.TOPIC:
      return 2;
      break;
    case RegularMessageType.WHO_IS:
      return 3;
      break;
    case RegularMessageType.UNHANDLED:
      return 4;
      break;
    case RegularMessageType.UNKNOWN:
      return 5;
      break;
    case RegularMessageType.MESSAGE:
      return 6;
      break;
    case RegularMessageType.JOIN:
      return 7;
      break;
    case RegularMessageType.MODE:
      return 8;
      break;
    case RegularMessageType.MOTD:
      return 9;
      break;
    case RegularMessageType.NOTICE:
      return 10;
      break;
    case RegularMessageType.ERROR:
      return 11;
      break;
    case RegularMessageType.AWAY:
      return 12;
      break;
    case RegularMessageType.BACK:
      return 13;
      break;
    case RegularMessageType.RAW:
      return 14;
      break;
    case RegularMessageType.MODE_CHANNEL:
      return 15;
      break;
    case RegularMessageType.QUIT:
      return 16;
      break;
    case RegularMessageType.PART:
      return 17;
      break;
    case RegularMessageType.NICK:
      return 18;
      break;
  }
  throw Exception("Invalid RegularMessageType = $type");
}

RegularMessageDB toRegularMessageDB(RegularMessage regularMessage) =>
    RegularMessageDB.name(
        command: regularMessage.command,
        hostMask: regularMessage.hostMask,
        text: regularMessage.text,
        regularMessageTypeId:
            regularMessageTypeTypeToId(regularMessage.regularMessageType),
        self: regularMessage.self != null ? regularMessage.self ? 1 : 0 : null,
        highlight: regularMessage.highlight != null
            ? regularMessage.highlight ? 1 : 0
            : null,
        paramsJsonEncoded: json.encode(regularMessage.params),
        previewsJsonEncoded: json.encode(regularMessage.previews),
        dateMicrosecondsSinceEpoch: regularMessage.date.microsecondsSinceEpoch,
        fromNick: regularMessage.fromNick,
        fromRemoteId: regularMessage.fromRemoteId,
        fromMode: regularMessage.fromMode,
        newNick: regularMessage.newNick,
        channelRemoteId: regularMessage.channelRemoteId);
