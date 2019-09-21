import 'dart:convert';

import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';



@Entity(tableName: "RegularMessage")
class RegularMessage implements ChatMessage {
  @PrimaryKey(autoGenerate: true)
  final int localId;

  
  int channelLocalId;

  final int chatMessageTypeId;

  final int channelRemoteId;

  
  final String command;
  
  final String hostMask;
  
  final String text;
  
  final String paramsJsonEncoded;


  static List<String> params(RegularMessage message) =>
      json.decode(message.paramsJsonEncoded);

//  List<String> get params => json.decode(paramsJsonEncoded);
  final int regularMessageTypeId;

  static RegularMessageType regularMessageType(RegularMessage message) =>
      regularMessageTypeIdToType(message.regularMessageTypeId);

//  RegularMessageType get regularMessageType =>
//      regularMessageTypeIdToType(regularMessageTypeId);


  // TODO: Replace with bool when SQFLite Floor ORM will support null for bool types
//  final bool self;
  final int self;

  static bool isSelf(RegularMessage message) => message.self != null ? message.self != 0 : null;

//  final bool highlight;
  final int highlight;
  static bool isHighlight(RegularMessage message) => message.highlight != null ? message.highlight != 0 : null;

  final String previewsJsonEncoded;

  static List<String> previews(RegularMessage message) =>
      json.decode(message.previewsJsonEncoded);

//  List<String> get previews =>
  final int dateMicrosecondsSinceEpoch;

  static DateTime date(RegularMessage message) =>
      DateTime.fromMicrosecondsSinceEpoch(message.dateMicrosecondsSinceEpoch);
  
  final int fromRemoteId;
  
  final String fromNick;
  
  final String fromMode;

  RegularMessage(
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
      this.fromMode);

  RegularMessage.name(
      {this.localId,
      this.channelLocalId,
      this.chatMessageTypeId = chatMessageTypeRegularId ,
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
      this.fromMode}); //  RegularMessage(


  static bool isHaveFromNick(RegularMessage message) =>
      message.fromNick != null;


  static bool isMessageDateToday(RegularMessage message) {
    var now = DateTime.now();
    var todayStart = now.subtract(
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second));
    return todayStart.isBefore(date(message));
  }

  @override
  String toString() {
    return 'RegularMessage{localId: $localId, channelLocalId: $channelLocalId, '
        'chatMessageTypeId: $chatMessageTypeId, channelRemoteId: $channelRemoteId,'
        ' command: $command, hostMask: $hostMask, text: $text, '
        'paramsJsonEncoded: $paramsJsonEncoded, '
        'regularMessageTypeId: $regularMessageTypeId, self: $self,'
        ' highlight: $highlight, previewsJsonEncoded: $previewsJsonEncoded,'
        ' dateMicrosecondsSinceEpoch: $dateMicrosecondsSinceEpoch, '
        'fromRemoteId: $fromRemoteId, fromNick: $fromNick, fromMode: $fromMode}';
  }


}

enum RegularMessageType {
  TOPIC_SET_BY,
  TOPIC,
  WHO_IS,
  UNHANDLED,
  UNKNOWN,
  MESSAGE,
  JOIN,
  MODE,
  MOTD,
  NOTICE,
  ERROR,
  AWAY,
  BACK,
  RAW,
  MODE_CHANNEL,
  QUIT,
  PART,
  NICK,
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
