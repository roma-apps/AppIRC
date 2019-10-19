// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoreLoungeRequestBody _$MoreLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return MoreLoungeRequestBody(
    json['target'] as int,
    json['lastId'] as int,
  );
}

Map<String, dynamic> _$MoreLoungeRequestBodyToJson(
        MoreLoungeRequestBody instance) =>
    <String, dynamic>{
      'target': instance.target,
      'lastId': instance.lastId,
    };

MsgPreviewToggleLoungeRequestBody _$MsgPreviewToggleLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return MsgPreviewToggleLoungeRequestBody(
    json['target'] as int,
    json['msgId'] as int,
    json['link'] as String,
    json['shown'] as bool,
  );
}

Map<String, dynamic> _$MsgPreviewToggleLoungeRequestBodyToJson(
        MsgPreviewToggleLoungeRequestBody instance) =>
    <String, dynamic>{
      'target': instance.target,
      'msgId': instance.msgId,
      'link': instance.link,
      'shown': instance.shown,
    };

PushTokenLoungeRequestBody _$PushTokenLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return PushTokenLoungeRequestBody(
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$PushTokenLoungeRequestBodyToJson(
        PushTokenLoungeRequestBody instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

NamesLoungeRequestBody _$NamesLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeRequestBody(
    json['target'] as int,
  );
}

Map<String, dynamic> _$NamesLoungeRequestBodyToJson(
        NamesLoungeRequestBody instance) =>
    <String, dynamic>{
      'target': instance.target,
    };

AuthLoungeRequestBody _$AuthLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return AuthLoungeRequestBody(
    json['user'] as String,
    json['password'] as String,
  );
}

Map<String, dynamic> _$AuthLoungeRequestBodyToJson(
        AuthLoungeRequestBody instance) =>
    <String, dynamic>{
      'user': instance.user,
      'password': instance.password,
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

NetworkEditLoungeRequestBody _$NetworkEditLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkEditLoungeRequestBody(
    host: json['host'] as String,
    commands: json['commands'] as String,
    uuid: json['uuid'] as String,
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

Map<String, dynamic> _$NetworkEditLoungeRequestBodyToJson(
        NetworkEditLoungeRequestBody instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'host': instance.host,
      'name': instance.name,
      'nick': instance.nick,
      'port': instance.port,
      'realname': instance.realname,
      'password': instance.password,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'tls': instance.tls,
      'username': instance.username,
      'commands': instance.commands,
    };
