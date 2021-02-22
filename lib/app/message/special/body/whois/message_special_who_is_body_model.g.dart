// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_special_who_is_body_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoIsSpecialMessageBody _$WhoIsSpecialMessageBodyFromJson(
    Map<String, dynamic> json) {
  return WhoIsSpecialMessageBody(
    account: json['account'] as String,
    channels: json['channels'] as String,
    hostname: json['hostname'] as String,
    actualHostname: json['actualHostname'] as String,
    actualIp: json['actualIp'] as String,
    ident: json['ident'] as String,
    idle: json['idle'] as String,
    idleTime: json['idleTime'] == null
        ? null
        : DateTime.parse(json['idleTime'] as String),
    logonTime: json['logonTime'] == null
        ? null
        : DateTime.parse(json['logonTime'] as String),
    logon: json['logon'] as String,
    nick: json['nick'] as String,
    realName: json['realName'] as String,
    secure: json['secure'] as bool,
    server: json['server'] as String,
    serverInfo: json['serverInfo'] as String,
  );
}

Map<String, dynamic> _$WhoIsSpecialMessageBodyToJson(
        WhoIsSpecialMessageBody instance) =>
    <String, dynamic>{
      'account': instance.account,
      'channels': instance.channels,
      'hostname': instance.hostname,
      'actualHostname': instance.actualHostname,
      'actualIp': instance.actualIp,
      'ident': instance.ident,
      'idle': instance.idle,
      'idleTime': instance.idleTime?.toIso8601String(),
      'logonTime': instance.logonTime?.toIso8601String(),
      'logon': instance.logon,
      'nick': instance.nick,
      'realName': instance.realName,
      'secure': instance.secure,
      'server': instance.server,
      'serverInfo': instance.serverInfo,
    };
