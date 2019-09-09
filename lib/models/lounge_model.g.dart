// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoungePreferences _$LoungePreferencesFromJson(Map<String, dynamic> json) {
  return LoungePreferences(
    host: json['host'] as String,
  );
}

Map<String, dynamic> _$LoungePreferencesToJson(LoungePreferences instance) =>
    <String, dynamic>{
      'host': instance.host,
    };

InputLoungeRequestBody _$InputLoungeRequestBodyFromJson(
    Map<String, dynamic> json) {
  return InputLoungeRequestBody(
    target: json['target'] as int,
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$InputLoungeRequestBodyToJson(
        InputLoungeRequestBody instance) =>
    <String, dynamic>{
      'target': instance.target,
      'text': instance.text,
    };

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

MessageLoungeResponseBody _$MessageLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MessageLoungeResponseBody(
    json['chan'] as int,
    json['msg'] == null
        ? null
        : MsgLoungeResponseBody.fromJson(json['msg'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MessageLoungeResponseBodyToJson(
        MessageLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'msg': instance.msg,
    };

JoinLoungeResponseBody _$JoinLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return JoinLoungeResponseBody(
    json['chan'] == null
        ? null
        : ChannelLoungeResponseBody.fromJson(
            json['chan'] as Map<String, dynamic>),
    json['index'] as int,
    json['network'] as String,
  );
}

Map<String, dynamic> _$JoinLoungeResponseBodyToJson(
        JoinLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'index': instance.index,
      'network': instance.network,
    };

NetworkStatusLoungeResponseBody _$NetworkStatusLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkStatusLoungeResponseBody(
    json['connected'] as bool,
    json['network'] as String,
    json['secure'] as bool,
  );
}

Map<String, dynamic> _$NetworkStatusLoungeResponseBodyToJson(
        NetworkStatusLoungeResponseBody instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'network': instance.network,
      'secure': instance.secure,
    };

NetworkOptionsLoungeResponseBody _$NetworkOptionsLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkOptionsLoungeResponseBody(
    json['network'] as String,
    json['serverOptions'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$NetworkOptionsLoungeResponseBodyToJson(
        NetworkOptionsLoungeResponseBody instance) =>
    <String, dynamic>{
      'network': instance.network,
      'serverOptions': instance.serverOptions,
    };

ChannelStateLoungeResponseBody _$ChannelStateLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChannelStateLoungeResponseBody(
    json['chan'] as int,
    json['state'] as int,
  );
}

Map<String, dynamic> _$ChannelStateLoungeResponseBodyToJson(
        ChannelStateLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'state': instance.state,
    };

UsersLoungeResponseBody _$UsersLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return UsersLoungeResponseBody(
    json['chan'] as int,
    json['msg'],
  );
}

Map<String, dynamic> _$UsersLoungeResponseBodyToJson(
        UsersLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'msg': instance.msg,
    };

MsgLoungeResponseBody _$MsgLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgLoungeResponseBody(
    json['from'] == null
        ? null
        : MsgFromLoungeResponseBody.fromJson(
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

Map<String, dynamic> _$MsgLoungeResponseBodyToJson(
        MsgLoungeResponseBody instance) =>
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

MsgFromLoungeResponseBody _$MsgFromLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgFromLoungeResponseBody(
    json['mode'],
    json['nick'] as String,
  );
}

Map<String, dynamic> _$MsgFromLoungeResponseBodyToJson(
        MsgFromLoungeResponseBody instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'nick': instance.nick,
    };

ConfigurationLoungeResponseBody _$ConfigurationLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ConfigurationLoungeResponseBody(
    json['defaultTheme'] as String,
    json['defaults'] as Map<String, dynamic>,
    json['displayNetwork'] as bool,
    json['fileUpload'] as bool,
    json['ldapEnabled'] as bool,
    json['lockNetwork'] as bool,
    json['prefetch'] as bool,
    json['public'] as bool,
    json['useHexIp'] as bool,
    json['fileUploadMaxSize'] as int,
    json['gitCommit'] as String,
    json['version'] as String,
    json['themes'] as List,
  );
}

Map<String, dynamic> _$ConfigurationLoungeResponseBodyToJson(
        ConfigurationLoungeResponseBody instance) =>
    <String, dynamic>{
      'defaultTheme': instance.defaultTheme,
      'defaults': instance.defaults,
      'displayNetwork': instance.displayNetwork,
      'fileUpload': instance.fileUpload,
      'ldapEnabled': instance.ldapEnabled,
      'lockNetwork': instance.lockNetwork,
      'prefetch': instance.prefetch,
      'public': instance.public,
      'useHexIp': instance.useHexIp,
      'fileUploadMaxSize': instance.fileUploadMaxSize,
      'gitCommit': instance.gitCommit,
      'version': instance.version,
      'themes': instance.themes,
    };

InitLoungeResponseBody _$InitLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return InitLoungeResponseBody(
    json['active'] as int,
    json['applicationServerKey'] as String,
    json['token'] as String,
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : NetworkLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$InitLoungeResponseBodyToJson(
        InitLoungeResponseBody instance) =>
    <String, dynamic>{
      'active': instance.active,
      'applicationServerKey': instance.applicationServerKey,
      'token': instance.token,
      'networks': instance.networks,
    };

NamesLoungeResponseBody _$NamesLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeResponseBody(
    json['id'] as int,
    (json['users'] as List)
        ?.map((e) => e == null
            ? null
            : UserLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NamesLoungeResponseBodyToJson(
        NamesLoungeResponseBody instance) =>
    <String, dynamic>{
      'id': instance.id,
      'users': instance.users,
    };

TopicLoungeResponseBody _$TopicLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return TopicLoungeResponseBody(
    json['chan'] as int,
    json['topic'] as String,
  );
}

Map<String, dynamic> _$TopicLoungeResponseBodyToJson(
        TopicLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'topic': instance.topic,
    };

UserLoungeResponseBodyPart _$UserLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return UserLoungeResponseBodyPart(
    json['lastMessage'] as int,
    json['mode'] as String,
    json['nick'] as String,
  );
}

Map<String, dynamic> _$UserLoungeResponseBodyPartToJson(
        UserLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'lastMessage': instance.lastMessage,
      'mode': instance.mode,
      'nick': instance.nick,
    };

NetworksLoungeResponseBody _$NetworksLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworksLoungeResponseBody(
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : NetworkLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NetworksLoungeResponseBodyToJson(
        NetworksLoungeResponseBody instance) =>
    <String, dynamic>{
      'networks': instance.networks,
    };

NetworkLoungeResponseBody _$NetworkLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkLoungeResponseBody(
    json['uuid'] as String,
    json['name'] as String,
    json['host'] as String,
    json['port'] as int,
    json['lts'] as String,
    json['userDisconnected'] as bool,
    json['rejectUnauthorized'] as bool,
    json['nick'] as String,
    json['username'] as String,
    json['realname'] as String,
    json['commands'] as List,
    (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : ChannelLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['serverOptions'] as Map<String, dynamic>,
    json['status'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$NetworkLoungeResponseBodyToJson(
        NetworkLoungeResponseBody instance) =>
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

ChannelLoungeResponseBody _$ChannelLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChannelLoungeResponseBody(
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

Map<String, dynamic> _$ChannelLoungeResponseBodyToJson(
        ChannelLoungeResponseBody instance) =>
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
