import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/message_db.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';

@dao
abstract class RegularMessageDao {
  static String createChannelMessagesCountQuery(Channel channel) =>
      'SELECT COUNT(*) FROM RegularMessageDB WHERE channelRemoteId = ${channel.remoteId}';

  static int extractCountFromQueryResult(List<Map<String, dynamic>> result) {
    var key = "COUNT(*)";
    var pair = result.firstWhere((map) {
      return map.containsKey(key);
    });

    return pair[key];
  }

  @Query('SELECT * FROM RegularMessageDB')
  Future<List<RegularMessageDB>> getAllMessages();

  @Query(
      'SELECT * FROM RegularMessageDB WHERE messageRemoteId = :messageRemoteId ')
  Future<RegularMessageDB> findMessageWithRemoteId(int messageRemoteId);

  @Query('SELECT localId FROM RegularMessageDB WHERE messageRemoteId = '
      ':messageRemoteId ')
  Future<RegularMessageDB> findMessageLocalIdWithRemoteId(int messageRemoteId);

  @Query(
      'SELECT * FROM RegularMessageDB WHERE messageRemoteId = :messageRemoteId '
      'AND channelRemoteId = :channelRemoteId')
  Future<RegularMessageDB> findMessageWithChannelAndRemoteId(
      int channelRemoteId, int messageRemoteId);

  @Query(
      'SELECT * FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<List<RegularMessageDB>> getChannelMessages(int channelRemoteId);

  @Query('SELECT * FROM RegularMessageDB WHERE channelRemoteId = '
      ':channelRemoteId ORDER BY dateMicrosecondsSinceEpoch ASC')
  Future<List<RegularMessageDB>> getChannelMessagesOrderByDate(
      int channelRemoteId);

  @Query('SELECT * FROM RegularMessageDB WHERE channelRemoteId = '
      ':channelRemoteId AND (text LIKE :search OR fromNick LIKE :nickSearch) ORDER '
      'BY '
      'dateMicrosecondsSinceEpoch ASC')
  Future<List<RegularMessageDB>> searchChannelMessagesOrderByDate(
      int channelRemoteId, String search, String nickSearch);

  @Query('SELECT * FROM RegularMessageDB ORDER BY messageRemoteId DESC LIMIT 1')
  Future<RegularMessageDB> getNewestAllChannelsMessage();

  @Query(
      'SELECT * FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId ORDER BY messageRemoteId DESC LIMIT 1')
  Future<RegularMessageDB> getNewestChannelMessage(int channelRemoteId);

  @Query(
      'SELECT * FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId ORDER BY messageRemoteId ASC LIMIT 1')
  Future<RegularMessageDB> getOldestChannelMessage(int channelRemoteId);

  @Query(
      'SELECT * FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId')
  Stream<List<RegularMessageDB>> getChannelMessagesStream(int channelRemoteId);

  @Query('SELECT * FROM RegularMessageDB WHERE channelRemoteId = '
      ':channelRemoteId ORDER BY dateMicrosecondsSinceEpoch ASC')
  Stream<List<RegularMessageDB>> getChannelMessagesOrderByDateStream(
      int channelRemoteId);

  @insert
  Future<int> insertRegularMessage(RegularMessageDB regularMessage);

  @update
  Future<int> updateRegularMessage(RegularMessageDB regularMessage);

  @transaction
  Future upsertRegularMessage(RegularMessage regularMessage) async {
    if (regularMessage.messageLocalId != null) {
      await updateRegularMessage(toRegularMessageDB(regularMessage));
    } else {
      var id = await insertRegularMessage(toRegularMessageDB(regularMessage));
      regularMessage.messageLocalId = id;
    }
    return regularMessage.messageLocalId;
  }

  Future findRegularMessageLocalIds(
      List<RegularMessage> regularMessages) async {
    for (var regularMessage in regularMessages) {
      var regularMessageDB =
          await findMessageLocalIdWithRemoteId(regularMessage.messageRemoteId);
      var localId = (regularMessageDB)?.localId;

      regularMessage.messageLocalId = localId;
    }
  }

  @transaction
  Future upsertRegularMessages(List<RegularMessage> messages) async {
    return await Future.wait(
      messages.map(
        (message) async => await upsertRegularMessage(
          message,
        ),
      ),
    );
  }

  @transaction
  Future insertRegularMessages(List<RegularMessageDB> messages) async {
    return await Future.wait(
      messages.map(
        (message) async => await insertRegularMessage(
          message,
        ),
      ),
    );
  }

  @transaction
  Future updateRegularMessages(List<RegularMessageDB> messages) async {
    return await Future.wait(
      messages.map(
        (message) async => await updateRegularMessage(
          message,
        ),
      ),
    );
  }

  @Query('DELETE FROM RegularMessageDB')
  Future<void> deleteAllRegularMessages();

  @Query(
      'DELETE FROM RegularMessageDB WHERE channelRemoteId = :channelRemoteId')
  Future<void> deleteChannelRegularMessages(int channelRemoteId);
}

@Entity(tableName: "RegularMessageDB")
class RegularMessageDB implements ChatMessageDB {
  @PrimaryKey(autoGenerate: true)
  int localId;

  @override
  int channelLocalId;

  @override
  final int chatMessageTypeId;

  @override
  final int channelRemoteId;

  final String command;

  final String hostMask;

  final String text;

  final String paramsJsonEncoded;

  final String nicknamesJsonEncoded;

  static List<String> params(RegularMessageDB message) =>
      json.decode(message.paramsJsonEncoded);

  final int regularMessageTypeId;

  static RegularMessageType regularMessageType(RegularMessageDB message) =>
      regularMessageTypeIdToType(message.regularMessageTypeId);

  // TODO: Replace with bool when SQFLite Floor ORM will support null for bool types
  final int self;

  static bool isSelf(RegularMessageDB message) =>
      message.self != null ? message.self != 0 : null;

  // TODO: Replace with bool when SQFLite Floor ORM will support null for bool types
  final int highlight;

  static bool isHighlight(RegularMessageDB message) =>
      message.highlight != null ? message.highlight != 0 : null;

  final String previewsJsonEncoded;
  @override
  final String linksJsonEncoded;

  static List<MessagePreview> previews(RegularMessageDB message) =>
      json.decode(message.previewsJsonEncoded);

  final int dateMicrosecondsSinceEpoch;

  static DateTime date(RegularMessageDB message) =>
      DateTime.fromMicrosecondsSinceEpoch(message.dateMicrosecondsSinceEpoch);

  final int fromRemoteId;

  final String fromNick;

  final String fromMode;
  final String newNick;
  final int messageRemoteId;

  RegularMessageDB({
    @required this.localId,
    @required this.channelLocalId,
    @required this.messageRemoteId,
    this.chatMessageTypeId = chatMessageTypeRegularId,
    @required this.channelRemoteId,
    @required this.command,
    @required this.hostMask,
    @required this.text,
    @required this.paramsJsonEncoded,
    @required this.regularMessageTypeId,
    @required this.self,
    @required this.highlight,
    @required this.previewsJsonEncoded,
    @required this.linksJsonEncoded,
    @required this.dateMicrosecondsSinceEpoch,
    @required this.fromRemoteId,
    @required this.fromNick,
    @required this.fromMode,
    @required this.newNick,
    @required this.nicknamesJsonEncoded,
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
        'nicknamesJsonEncoded: $nicknamesJsonEncoded'
        'fromMode: $fromMode, newNick: $newNick}';
  } //  RegularMessage(

}

RegularMessageType regularMessageTypeIdToType(int id) {
  switch (id) {
    case 1:
      return RegularMessageType.topicSetBy;
      break;
    case 2:
      return RegularMessageType.topic;
      break;
    case 3:
      return RegularMessageType.whoIs;
      break;
    case 4:
      return RegularMessageType.unhandled;
      break;
    case 5:
      return RegularMessageType.unknown;
      break;
    case 6:
      return RegularMessageType.message;
      break;
    case 7:
      return RegularMessageType.join;
      break;
    case 8:
      return RegularMessageType.mode;
      break;
    case 9:
      return RegularMessageType.motd;
      break;
    case 10:
      return RegularMessageType.notice;
      break;
    case 11:
      return RegularMessageType.error;
      break;
    case 12:
      return RegularMessageType.away;
      break;
    case 13:
      return RegularMessageType.back;
      break;
    case 14:
      return RegularMessageType.raw;
      break;
    case 15:
      return RegularMessageType.modeChannel;
      break;
    case 16:
      return RegularMessageType.quit;
      break;
    case 17:
      return RegularMessageType.part;
      break;
    case 18:
      return RegularMessageType.nick;
      break;
    case 19:
      return RegularMessageType.ctcpRequest;
      break;
    case 20:
      return RegularMessageType.chghost;
      break;
    case 21:
      return RegularMessageType.kick;
      break;
    case 22:
      return RegularMessageType.action;
      break;
    case 23:
      return RegularMessageType.invite;
      break;
    case 24:
      return RegularMessageType.ctcp;
      break;
    case 25:
      return RegularMessageType.monospaceBlock;
      break;
  }

  throw Exception("Invalid RegularMessageType id $id");
}

int regularMessageTypeTypeToId(RegularMessageType type) {
  switch (type) {
    case RegularMessageType.topicSetBy:
      return 1;
      break;
    case RegularMessageType.topic:
      return 2;
      break;
    case RegularMessageType.whoIs:
      return 3;
      break;
    case RegularMessageType.unhandled:
      return 4;
      break;
    case RegularMessageType.unknown:
      return 5;
      break;
    case RegularMessageType.message:
      return 6;
      break;
    case RegularMessageType.join:
      return 7;
      break;
    case RegularMessageType.mode:
      return 8;
      break;
    case RegularMessageType.motd:
      return 9;
      break;
    case RegularMessageType.notice:
      return 10;
      break;
    case RegularMessageType.error:
      return 11;
      break;
    case RegularMessageType.away:
      return 12;
      break;
    case RegularMessageType.back:
      return 13;
      break;
    case RegularMessageType.raw:
      return 14;
      break;
    case RegularMessageType.modeChannel:
      return 15;
      break;
    case RegularMessageType.quit:
      return 16;
      break;
    case RegularMessageType.part:
      return 17;
      break;
    case RegularMessageType.nick:
      return 18;
      break;
    case RegularMessageType.ctcpRequest:
      return 19;
      break;
    case RegularMessageType.chghost:
      return 20;
      break;
    case RegularMessageType.kick:
      return 21;
      break;
    case RegularMessageType.action:
      return 22;
      break;
    case RegularMessageType.invite:
      return 23;
      break;
    case RegularMessageType.ctcp:
      return 24;
      break;
    case RegularMessageType.monospaceBlock:
      return 25;
      break;
  }
  throw Exception("Invalid RegularMessageType = $type");
}

RegularMessageDB toRegularMessageDB(RegularMessage regularMessage) =>
    RegularMessageDB(
      messageRemoteId: regularMessage.messageRemoteId,
      command: regularMessage.command,
      hostMask: regularMessage.hostMask,
      text: regularMessage.text,
      regularMessageTypeId:
          regularMessageTypeTypeToId(regularMessage.regularMessageType),
      self: regularMessage.self != null
          ? regularMessage.self
              ? 1
              : 0
          : null,
      highlight: regularMessage.highlight != null
          ? regularMessage.highlight
              ? 1
              : 0
          : null,
      paramsJsonEncoded: json.encode(regularMessage.params),
      nicknamesJsonEncoded: json.encode(regularMessage.nicknames),
      previewsJsonEncoded: regularMessage.previews != null
          ? json.encode(regularMessage.previews
              .map((preview) => preview.toJson())
              .toList())
          : null,
      linksJsonEncoded: regularMessage.linksInMessage != null
          ? json.encode(regularMessage.linksInMessage)
          : null,
      dateMicrosecondsSinceEpoch: regularMessage.date.microsecondsSinceEpoch,
      fromNick: regularMessage.fromNick,
      fromRemoteId: regularMessage.fromRemoteId,
      fromMode: regularMessage.fromMode,
      newNick: regularMessage.newNick,
      channelRemoteId: regularMessage.channelRemoteId,
      localId: null,
      channelLocalId: null,
    );

RegularMessage regularMessageDBToChatMessage(RegularMessageDB messageDB) =>
    RegularMessage(
      channelRemoteId: messageDB.channelRemoteId,
      messageLocalId: messageDB.localId,
      messageRemoteId: messageDB.messageRemoteId,
      command: messageDB.command,
      hostMask: messageDB.hostMask,
      text: messageDB.text,
      params: messageDB.paramsJsonEncoded != null
          ? _convertParams(messageDB)
          : null,
      regularMessageType:
          regularMessageTypeIdToType(messageDB.regularMessageTypeId),
      self: messageDB.self != null
          ? messageDB.self == 0
              ? false
              : true
          : null,
      highlight: messageDB.highlight != null
          ? messageDB.highlight == 0
              ? false
              : true
          : null,
      previews: messageDB.previewsJsonEncoded != null
          ? _convertPreviews(messageDB)
          : null,
      linksInMessage:
          messageDB.linksJsonEncoded != null ? convertLinks(messageDB) : null,
      date: DateTime.fromMicrosecondsSinceEpoch(
        messageDB.dateMicrosecondsSinceEpoch,
      ),
      fromRemoteId: messageDB.fromRemoteId,
      fromNick: messageDB.fromNick,
      fromMode: messageDB.fromMode,
      newNick: messageDB.newNick,
      nicknames: messageDB.nicknamesJsonEncoded != null
          ? _convertNicknames(messageDB)
          : null,
      channelLocalId: null,
    );

List<String> _convertNicknames(RegularMessageDB messageDB) {
  var decoded = json.decode(messageDB.nicknamesJsonEncoded);

  if (decoded == null) {
    return null;
  } else if (decoded is List<dynamic>) {
    decoded =
        (decoded as List<dynamic>).map((item) => item.toString()).toList();
  }
  return decoded;
}

List<String> _convertParams(RegularMessageDB messageDB) {
  var decoded = json.decode(messageDB.paramsJsonEncoded);

  if (decoded == null) {
    return null;
  } else if (decoded is List<dynamic>) {
    decoded =
        (decoded as List<dynamic>).map((item) => item.toString()).toList();
  }
  return decoded;
}

List<MessagePreview> _convertPreviews(RegularMessageDB messageDB) {
  var decoded = json.decode(messageDB.previewsJsonEncoded);
  var list = decoded as List<dynamic>;

  return list.map((listItem) => MessagePreview.fromJson(listItem)).toList();
}
