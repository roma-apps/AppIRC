// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InputLoungeJsonRequest _$InputLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return InputLoungeJsonRequest(
    json['target'] as int,
    json['content'] as String,
  );
}

Map<String, dynamic> _$InputLoungeJsonRequestToJson(
        InputLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.target,
      'content': instance.content,
    };

MoreLoungeJsonRequest _$MoreLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return MoreLoungeJsonRequest(
    json['target'] as int,
    json['lastId'] as int,
  );
}

Map<String, dynamic> _$MoreLoungeJsonRequestToJson(
        MoreLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.target,
      'lastId': instance.lastId,
    };

MsgPreviewToggleLoungeJsonRequest _$MsgPreviewToggleLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return MsgPreviewToggleLoungeJsonRequest(
    json['target'] as int,
    json['msgId'] as int,
    json['link'] as String,
    json['shown'] as bool,
  );
}

Map<String, dynamic> _$MsgPreviewToggleLoungeJsonRequestToJson(
        MsgPreviewToggleLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.target,
      'msgId': instance.msgId,
      'link': instance.link,
      'shown': instance.shown,
    };

PushFCMTokenLoungeJsonRequest _$PushFCMTokenLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return PushFCMTokenLoungeJsonRequest(
    json['token'] as String,
  );
}

Map<String, dynamic> _$PushFCMTokenLoungeJsonRequestToJson(
        PushFCMTokenLoungeJsonRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

NamesLoungeJsonRequest _$NamesLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeJsonRequest(
    json['target'] as int,
  );
}

Map<String, dynamic> _$NamesLoungeJsonRequestToJson(
        NamesLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.target,
    };

AuthLoungeJsonRequestBody _$AuthLoungeJsonRequestBodyFromJson(
    Map<String, dynamic> json) {
  return AuthLoungeJsonRequestBody(
    json['user'] as String,
    json['password'] as String,
  );
}

Map<String, dynamic> _$AuthLoungeJsonRequestBodyToJson(
        AuthLoungeJsonRequestBody instance) =>
    <String, dynamic>{
      'user': instance.user,
      'password': instance.password,
    };

NetworkEditLoungeJsonRequest _$NetworkEditLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return NetworkEditLoungeJsonRequest(
    json['uuid'] as String,
    json['host'] as String,
    json['name'] as String,
    json['nick'] as String,
    json['port'] as String,
    json['realname'] as String,
    json['password'] as String,
    json['rejectUnauthorized'] as String,
    json['tls'] as String,
    json['username'] as String,
    json['commands'] as String,
  );
}

Map<String, dynamic> _$NetworkEditLoungeJsonRequestToJson(
        NetworkEditLoungeJsonRequest instance) =>
    <String, dynamic>{
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
      'uuid': instance.uuid,
    };

NetworkNewLoungeJsonRequest _$NetworkNewLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return NetworkNewLoungeJsonRequest(
    json['join'] as String,
    json['host'] as String,
    json['name'] as String,
    json['nick'] as String,
    json['port'] as String,
    json['realname'] as String,
    json['password'] as String,
    json['rejectUnauthorized'] as String,
    json['tls'] as String,
    json['username'] as String,
    json['commands'] as String,
  );
}

Map<String, dynamic> _$NetworkNewLoungeJsonRequestToJson(
        NetworkNewLoungeJsonRequest instance) =>
    <String, dynamic>{
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
      'join': instance.join,
    };
