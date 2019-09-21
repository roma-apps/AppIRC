import 'package:floor/floor.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'messages_model.dart';

part 'messages_special_model.g.dart';

@Entity(tableName: "SpecialMessage")
class SpecialMessage implements ChatMessage {
  @PrimaryKey(autoGenerate: true)
  final int localId;


  int channelLocalId;

  final int chatMessageTypeId;

  final int channelRemoteId;

  final String dataJsonEncoded;
  int specialTypeId;

  SpecialMessage(this.localId, this.channelLocalId, this.chatMessageTypeId,
      this.channelRemoteId, this.dataJsonEncoded, this.specialTypeId);

  SpecialMessage.name(
      {this.localId,
      this.channelLocalId,
      this.chatMessageTypeId = chatMessageTypeSpecialId,
      @required this.channelRemoteId,
      @required this.dataJsonEncoded,
      @required this.specialTypeId});

//  SpecialMessageType get specialType => specialMessageTypeIdToType(specialTypeId);

}

enum SpecialMessageType { WHO_IS, CHANNELS_LIST_ITEM, TEXT }

abstract class SpecialMessageBody {
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class WhoIsSpecialMessageBody extends SpecialMessageBody {
  final String account;
  final String channels;
  final String hostname;
  final String ident;
  final String idle;
  final int idleTime;
  final int logonTime;
  final String logon;
  final String nick;
  final String realName;
  final bool secure;
  final String server;
  final String serverInfo;

  @override
  String toString() {
    return 'IRCNetworkChannelMessageWhoIS{account: $account, '
        'channels: $channels, hostname: $hostname, '
        'ident: $ident, idle: $idle, idleTime: $idleTime, '
        'logonTime: $logonTime, logon: $logon, nick: $nick, '
        'realName: $realName, secure: $secure, '
        'server: $server, serverInfo: $serverInfo}';
  }

  WhoIsSpecialMessageBody(
      this.account,
      this.channels,
      this.hostname,
      this.ident,
      this.idle,
      this.idleTime,
      this.logonTime,
      this.logon,
      this.nick,
      this.realName,
      this.secure,
      this.server,
      this.serverInfo);

  WhoIsSpecialMessageBody.name(
      {@required this.account,
      @required this.channels,
      @required this.hostname,
      @required this.ident,
      @required this.idle,
      @required this.idleTime,
      @required this.logonTime,
      @required this.logon,
      @required this.nick,
      @required this.realName,
      @required this.secure,
      @required this.server,
      @required this.serverInfo});

  factory WhoIsSpecialMessageBody.fromJson(Map<String, dynamic> json) =>
      _$WhoIsSpecialMessageBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WhoIsSpecialMessageBodyToJson(this);
}

@JsonSerializable()
class NetworkChannelInfoSpecialMessageBody extends SpecialMessageBody {
  final String name;
  final String topic;
  final int usersCount;

  @override
  String toString() {
    return 'NetworkChannelInfoSpecialMessageBody{name: $name, '
        'topic: $topic, usersCount: $usersCount}';
  }

  NetworkChannelInfoSpecialMessageBody(this.name, this.topic, this.usersCount);

  NetworkChannelInfoSpecialMessageBody.name(
      {@required this.name, @required this.topic, @required this.usersCount});

  factory NetworkChannelInfoSpecialMessageBody.fromJson(
          Map<String, dynamic> json) =>
      _$NetworkChannelInfoSpecialMessageBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$NetworkChannelInfoSpecialMessageBodyToJson(this);
}

@JsonSerializable()
class TextSpecialMessageBody extends SpecialMessageBody {
  final String message;

  TextSpecialMessageBody(this.message);

  @override
  String toString() {
    return 'LoadingSpecialMessageBody{message: $message}';
  }

  TextSpecialMessageBody.name({@required this.message});

  factory TextSpecialMessageBody.fromJson(Map<String, dynamic> json) =>
      _$TextSpecialMessageBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TextSpecialMessageBodyToJson(this);
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
