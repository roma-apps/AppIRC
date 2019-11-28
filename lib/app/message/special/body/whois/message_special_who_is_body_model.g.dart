// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_special_who_is_body_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoIsSpecialMessageBody _$WhoIsSpecialMessageBodyFromJson(
    Map<String, dynamic> json) {
  return WhoIsSpecialMessageBody(
    json['account'] as String,
    json['channels'] as String,
    json['hostname'] as String,
    json['actualHostname'] as String,
    json['actualIp'] as String,
    json['ident'] as String,
    json['idle'] as String,
    json['idleTime'] == null
        ? null
        : DateTime.parse(json['idleTime'] as String),
    json['logonTime'] == null
        ? null
        : DateTime.parse(json['logonTime'] as String),
    json['logon'] as String,
    json['nick'] as String,
    json['realName'] as String,
    json['secure'] as bool,
    json['server'] as String,
    json['serverInfo'] as String,
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
