// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushFCMTokenLoungeJsonRequest _$PushFCMTokenLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return PushFCMTokenLoungeJsonRequest(
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$PushFCMTokenLoungeJsonRequestToJson(
        PushFCMTokenLoungeJsonRequest instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

InputLoungeJsonRequest _$InputLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return InputLoungeJsonRequest(
    target: json['target'] as int,
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$InputLoungeJsonRequestToJson(
        InputLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.target,
      'text': instance.text,
    };

MoreLoungeJsonRequest _$MoreLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return MoreLoungeJsonRequest(
    target: json['target'] as int,
    lastId: json['lastId'] as int,
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
    target: json['target'] as int,
    msgId: json['msgId'] as int,
    link: json['link'] as String,
    shown: json['shown'] as bool,
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

NamesLoungeJsonRequest _$NamesLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeJsonRequest(
    target: json['target'] as int,
  );
}

Map<String, dynamic> _$NamesLoungeJsonRequestToJson(
        NamesLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.target,
    };

RegistrationLoungeJsonRequest _$RegistrationLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return RegistrationLoungeJsonRequest(
    user: json['user'] as String,
    password: json['password'] as String,
  );
}

Map<String, dynamic> _$RegistrationLoungeJsonRequestToJson(
        RegistrationLoungeJsonRequest instance) =>
    <String, dynamic>{
      'user': instance.user,
      'password': instance.password,
    };

AuthLoginLoungeJsonRequestBody _$AuthLoginLoungeJsonRequestBodyFromJson(
    Map<String, dynamic> json) {
  return AuthLoginLoungeJsonRequestBody(
    user: json['user'] as String,
    password: json['password'] as String,
  );
}

Map<String, dynamic> _$AuthLoginLoungeJsonRequestBodyToJson(
        AuthLoginLoungeJsonRequestBody instance) =>
    <String, dynamic>{
      'user': instance.user,
      'password': instance.password,
    };

AuthReconnectLoungeJsonRequestBody _$AuthReconnectLoungeJsonRequestBodyFromJson(
    Map<String, dynamic> json) {
  return AuthReconnectLoungeJsonRequestBody(
    lastMessageId: json['lastMessage'] as int,
    openChannelId: json['openChannel'] as int,
    user: json['user'] as String,
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$AuthReconnectLoungeJsonRequestBodyToJson(
        AuthReconnectLoungeJsonRequestBody instance) =>
    <String, dynamic>{
      'lastMessage': instance.lastMessageId,
      'openChannel': instance.openChannelId,
      'user': instance.user,
      'token': instance.token,
    };

NetworkEditLoungeJsonRequest _$NetworkEditLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return NetworkEditLoungeJsonRequest(
    uuid: json['uuid'] as String,
    host: json['host'] as String,
    name: json['name'] as String,
    nick: json['nick'] as String,
    port: json['port'] as String,
    realname: json['realname'] as String,
    password: json['password'] as String,
    rejectUnauthorized: json['rejectUnauthorized'] as String,
    tls: json['tls'] as String,
    username: json['username'] as String,
    commands: json['commands'] as String,
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
    join: json['join'] as String,
    host: json['host'] as String,
    name: json['name'] as String,
    nick: json['nick'] as String,
    port: json['port'] as String,
    realname: json['realname'] as String,
    password: json['password'] as String,
    rejectUnauthorized: json['rejectUnauthorized'] as String,
    tls: json['tls'] as String,
    username: json['username'] as String,
    commands: json['commands'] as String,
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
