import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import 'messages_model.dart';

part 'messages_special_model.g.dart';

class SpecialMessage extends ChatMessage {
  final SpecialMessageBody data;
  final SpecialMessageType specialType;

  SpecialMessage(int channelLocalId, int channelRemoteId, this.specialType,
      this.data, DateTime date)
      : super(ChatMessageType.SPECIAL, channelRemoteId, date);

  SpecialMessage.name(
      {@required int channelRemoteId,
      @required this.data,
      @required this.specialType,
      @required DateTime date})
      : super(ChatMessageType.SPECIAL, channelRemoteId, date);
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
  final String actualHostname;
  final String actualIp;
  final String ident;
  final String idle;
  final DateTime idleTime;
  final DateTime logonTime;
  final String logon;
  final String nick;
  final String realName;
  final bool secure;
  final String server;
  final String serverInfo;

  @override
  String toString() {
    return 'WhoIsSpecialMessageBody{account: $account, '
        'channels: $channels, hostname: $hostname, '
        'ident: $ident, idle: $idle, idleTime: $idleTime, '
        'logonTime: $logonTime, logon: $logon, nick: $nick, '
        'realName: $realName, secure: $secure, '
        'actualIp: $actualIp, actualHostname: $actualHostname, '
        'server: $server, serverInfo: $serverInfo}';
  }

  WhoIsSpecialMessageBody(
      this.account,
      this.channels,
      this.hostname,
      this.actualHostname,
      this.actualIp,
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
      @required this.actualHostname,
      @required this.actualIp,
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
