// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_special_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoIsSpecialMessageBody _$WhoIsSpecialMessageBodyFromJson(
    Map<String, dynamic> json) {
  return WhoIsSpecialMessageBody(
    json['account'] as String,
    json['channels'] as String,
    json['hostname'] as String,
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

NetworkChannelInfoSpecialMessageBody
    _$NetworkChannelInfoSpecialMessageBodyFromJson(Map<String, dynamic> json) {
  return NetworkChannelInfoSpecialMessageBody(
    json['name'] as String,
    json['topic'] as String,
    json['usersCount'] as int,
  );
}

Map<String, dynamic> _$NetworkChannelInfoSpecialMessageBodyToJson(
        NetworkChannelInfoSpecialMessageBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'topic': instance.topic,
      'usersCount': instance.usersCount,
    };

TextSpecialMessageBody _$TextSpecialMessageBodyFromJson(
    Map<String, dynamic> json) {
  return TextSpecialMessageBody(
    json['message'] as String,
  );
}

Map<String, dynamic> _$TextSpecialMessageBodyToJson(
        TextSpecialMessageBody instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
