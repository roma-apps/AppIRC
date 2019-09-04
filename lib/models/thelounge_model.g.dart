// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thelounge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InputTheLoungeRequestBody _$InputTheLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return InputTheLoungeRequestBody(
    target: json['target'] as int,
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$InputTheLoungeRequestBodyToJson(
        InputTheLoungeRequestBody instance) =>
    <String, dynamic>{
      'target': instance.target,
      'text': instance.text,
    };

NetworkNewTheLoungeRequestBody _$NetworkNewTheLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkNewTheLoungeRequestBody(
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

Map<String, dynamic> _$NetworkNewTheLoungeRequestBodyToJson(
        NetworkNewTheLoungeRequestBody instance) =>
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

MessageTheLoungeResponseBody _$MessageTheLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MessageTheLoungeResponseBody(
    json['chan'] as int,
    json['msg'] == null
        ? null
        : MsgTheLoungeResponseBody.fromJson(
            json['msg'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MessageTheLoungeResponseBodyToJson(
        MessageTheLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'msg': instance.msg,
    };

MsgTheLoungeResponseBody _$MsgTheLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgTheLoungeResponseBody(
    json['from'] == null
        ? null
        : MsgFromTheLoungeResponseBody.fromJson(
            json['from'] as Map<String, dynamic>),
    json['type'] as String,
    json['time'] as String,
    json['text'] as String,
    json['self'] as bool,
    json['highlight'] as bool,
    json['showInActive'] as bool,
    json['users'] as List,
    json['previews'] as List,
    json['id'] as int,
  );
}

Map<String, dynamic> _$MsgTheLoungeResponseBodyToJson(
        MsgTheLoungeResponseBody instance) =>
    <String, dynamic>{
      'from': instance.from,
      'type': instance.type,
      'time': instance.time,
      'text': instance.text,
      'self': instance.self,
      'highlight': instance.highlight,
      'showInActive': instance.showInActive,
      'users': instance.users,
      'previews': instance.previews,
      'id': instance.id,
    };

MsgFromTheLoungeResponseBody _$MsgFromTheLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgFromTheLoungeResponseBody(
    json['mode'],
    json['nick'] as String,
  );
}

Map<String, dynamic> _$MsgFromTheLoungeResponseBodyToJson(
        MsgFromTheLoungeResponseBody instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'nick': instance.nick,
    };

NetworksTheLoungeResponseBody _$NetworksTheLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworksTheLoungeResponseBody(
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : NetworkTheLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NetworksTheLoungeResponseBodyToJson(
        NetworksTheLoungeResponseBody instance) =>
    <String, dynamic>{
      'networks': instance.networks,
    };

NetworkTheLoungeResponseBody _$NetworkTheLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkTheLoungeResponseBody(
    json['uuid'] as String,
    json['name'] as String,
    json['host'] as String,
    json['port'] as String,
    json['lts'] as String,
    json['userDisconnected'] as String,
    json['rejectUnauthorized'] as String,
    json['nick'] as String,
    json['username'] as String,
    json['realname'] as String,
    json['commands'] as List,
    (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : ChannelTheLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['serverOptions'] as Map<String, dynamic>,
    json['status'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$NetworkTheLoungeResponseBodyToJson(
        NetworkTheLoungeResponseBody instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'host': instance.host,
      'port': instance.port,
      'lts': instance.lts,
      'userDisconnected': instance.userDisconnected,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'nick': instance.nick,
      'username': instance.username,
      'realname': instance.realname,
      'commands': instance.commands,
      'channels': instance.channels,
      'serverOptions': instance.serverOptions,
      'status': instance.status,
    };

ChannelTheLoungeResponseBody _$ChannelTheLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChannelTheLoungeResponseBody(
    json['name'] as String,
    json['type'] as String,
    json['id'] as int,
    json['messages'] as List,
    json['moreHistoryAvailable'] as bool,
    json['key'] as String,
    json['topic'] as String,
    json['state'] as int,
    json['firstUnread'] as int,
    json['unread'] as int,
    json['highlight'] as int,
    json['users'] as List,
  );
}

Map<String, dynamic> _$ChannelTheLoungeResponseBodyToJson(
        ChannelTheLoungeResponseBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'id': instance.id,
      'messages': instance.messages,
      'moreHistoryAvailable': instance.moreHistoryAvailable,
      'key': instance.key,
      'topic': instance.topic,
      'state': instance.state,
      'firstUnread': instance.firstUnread,
      'unread': instance.unread,
      'highlight': instance.highlight,
      'users': instance.users,
    };
