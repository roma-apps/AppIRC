// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NamesLoungeRequestBody _$NamesLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeRequestBody(
    target: json['target'] as int,
  );
}

Map<String, dynamic> _$NamesLoungeRequestBodyToJson(
        NamesLoungeRequestBody instance) =>
    <String, dynamic>{
      'target': instance.target,
    };

NetworkNewLoungeRequestBody _$NetworkNewLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkNewLoungeRequestBody(
    host: json['host'] as String,
    join: json['join'] as String,
    name: json['name'] as String,
    nick: json['nick'] as String,
    port: json['port'] as String,
    realname: json['realname'] as String,
    rejectUnauthorized: json['rejectUnauthorized'] as String,
    tls: json['tls'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
  );
}

Map<String, dynamic> _$NetworkNewLoungeRequestBodyToJson(
        NetworkNewLoungeRequestBody instance) =>
    <String, dynamic>{
      'host': instance.host,
      'join': instance.join,
      'name': instance.name,
      'nick': instance.nick,
      'port': instance.port,
      'realname': instance.realname,
      'password': instance.password,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'tls': instance.tls,
      'username': instance.username,
    };
