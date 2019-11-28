import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/body/message_special_body_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_special_who_is_body_model.g.dart';

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
