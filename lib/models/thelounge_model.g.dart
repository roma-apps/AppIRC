// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thelounge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkNewTheLoungeRequestBody _$NetworkNewTheLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkNewTheLoungeRequestBody(
    json['host'] as String,
    json['join'] as String,
    json['name'] as String,
    json['nick'] as String,
    json['port'] as String,
    json['realname'] as String,
    json['rejectUnauthorized'] as String,
    json['tls'] as String,
    json['username'] as String,
  );
}

Map<String, dynamic> _$NetworkNewTheLoungeRequestBodyToJson(
        NetworkNewTheLoungeRequestBody instance) =>
    <String, dynamic>{
      'host': instance.host,
      'join': instance.join,
      'name': instance.name,
      'nick': instance.nick,
      'port': instance.port,
      'realname': instance.realname,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'tls': instance.tls,
      'username': instance.username,
    };
