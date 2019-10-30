import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:json_annotation/json_annotation.dart';


part 'message_special_model.g.dart';

class SpecialMessage extends ChatMessage {
  final SpecialMessageBody data;
  final SpecialMessageType specialType;

  SpecialMessage(int channelLocalId, int channelRemoteId, this.specialType,
      this.data, DateTime date, List<String> linksInText)
      : super(ChatMessageType.special, channelRemoteId, date, linksInText);

  SpecialMessage.name(
      {@required int channelRemoteId,
      @required this.data,
      @required this.specialType,
      int messageLocalId,
      @required DateTime date,
      @required List<String> linksInMessage})
      : super(
          ChatMessageType.special,
          channelRemoteId,
          date,
          linksInMessage,
          messageLocalId: messageLocalId,
        );

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) =>
      data.isContainsText(searchTerm, ignoreCase: ignoreCase);
  @override
  String toString() {
    return 'SpecialMessage{data: $data,'
        ' specialType: $specialType'
        ' messageLocalId: $messageLocalId,'
        ' channelRemoteId: $channelRemoteId,'
        ' channelLocalId: $channelLocalId,'
        '}';
  }


}

enum SpecialMessageType { whoIs, channelsListItem, text }

abstract class SpecialMessageBody {
  Map<String, dynamic> toJson();

  bool isContainsText(String searchTerm, {@required bool ignoreCase});
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

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) =>
      isContainsSearchTerm(nick, searchTerm, ignoreCase: ignoreCase);
}

@JsonSerializable()
class ChannelInfoSpecialMessageBody extends SpecialMessageBody {
  final String name;
  final String topic;
  final int usersCount;

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) {
    var contains = false;

    contains |= isContainsSearchTerm(name, searchTerm, ignoreCase: ignoreCase);
    if (!contains) {
      contains |=
          isContainsSearchTerm(topic, searchTerm, ignoreCase: ignoreCase);
    }

    return contains;
  }

  @override
  String toString() {
    return 'ChannelInfoSpecialMessageBody{name: $name, '
        'topic: $topic, usersCount: $usersCount}';
  }

  ChannelInfoSpecialMessageBody(this.name, this.topic, this.usersCount);

  ChannelInfoSpecialMessageBody.name(
      {@required this.name, @required this.topic, @required this.usersCount});

  factory ChannelInfoSpecialMessageBody.fromJson(
          Map<String, dynamic> json) =>
      _$ChannelInfoSpecialMessageBodyFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChannelInfoSpecialMessageBodyToJson(this);
}

@JsonSerializable()
class TextSpecialMessageBody extends SpecialMessageBody {
  final String message;

  @override
  bool isContainsText(String searchTerm, {@required bool ignoreCase}) =>
      isContainsSearchTerm(message, searchTerm, ignoreCase: ignoreCase);

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
