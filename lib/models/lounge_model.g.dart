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

ChanLoungeResponseBody _$ChanLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChanLoungeResponseBody(
    json['chan'] as int,
  );
}

Map<String, dynamic> _$ChanLoungeResponseBodyToJson(
        ChanLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
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
    json['highlight'] as int,
    json['unread'] as int,
    json['msg'] == null
        ? null
        : MsgLoungeResponseBody.fromJson(json['msg'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MessageLoungeResponseBodyToJson(
        MessageLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'highlight': instance.highlight,
      'unread': instance.unread,
      'msg': instance.msg,
    };

MessageSpecialLoungeResponseBody _$MessageSpecialLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MessageSpecialLoungeResponseBody(
    json['chan'] as int,
    json['data'],
  );
}

Map<String, dynamic> _$MessageSpecialLoungeResponseBodyToJson(
        MessageSpecialLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'data': instance.data,
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
    json['serverOptions'] == null
        ? null
        : ServerOptionsLoungeResponseBodyPart.fromJson(
            json['serverOptions'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NetworkOptionsLoungeResponseBodyToJson(
        NetworkOptionsLoungeResponseBody instance) =>
    <String, dynamic>{
      'network': instance.network,
      'serverOptions': instance.serverOptions,
    };

ServerOptionsLoungeResponseBodyPart
    _$ServerOptionsLoungeResponseBodyPartFromJson(Map<String, dynamic> json) {
  return ServerOptionsLoungeResponseBodyPart(
    (json['CHANTYPES'] as List)?.map((e) => e as String)?.toList(),
    json['NETWORK'] as String,
    (json['PREFIX'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$ServerOptionsLoungeResponseBodyPartToJson(
        ServerOptionsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'CHANTYPES': instance.CHANTYPES,
      'NETWORK': instance.NETWORK,
      'PREFIX': instance.PREFIX,
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
    json['unread'] as int,
    json['msg'],
    json['highlight'] as int,
  );
}

Map<String, dynamic> _$UsersLoungeResponseBodyToJson(
        UsersLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'unread': instance.unread,
      'highlight': instance.highlight,
      'msg': instance.msg,
    };

NickLoungeResponseBody _$NickLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NickLoungeResponseBody(
    json['network'] as String,
    json['nick'] as String,
  );
}

Map<String, dynamic> _$NickLoungeResponseBodyToJson(
        NickLoungeResponseBody instance) =>
    <String, dynamic>{
      'network': instance.network,
      'nick': instance.nick,
    };

MsgLoungeResponseBody _$MsgLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgLoungeResponseBody(
    json['from'] == null
        ? null
        : MsgFromLoungeResponseBodyPart.fromJson(
            json['from'] as Map<String, dynamic>),
    json['command'] as String,
    json['type'] as String,
    json['time'] as String,
    json['text'] as String,
    json['hostmask'] as String,
    json['self'] as bool,
    json['highlight'] as bool,
    json['showInActive'] as bool,
    json['users'] as List,
    json['previews'] as List,
    (json['params'] as List)?.map((e) => e as String)?.toList(),
    json['id'] as int,
    json['whois'] == null
        ? null
        : WhoIsLoungeResponseBodyPart.fromJson(
            json['whois'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MsgLoungeResponseBodyToJson(
        MsgLoungeResponseBody instance) =>
    <String, dynamic>{
      'from': instance.from,
      'command': instance.command,
      'type': instance.type,
      'time': instance.time,
      'text': instance.text,
      'hostmask': instance.hostmask,
      'self': instance.self,
      'highlight': instance.highlight,
      'showInActive': instance.showInActive,
      'users': instance.users,
      'previews': instance.previews,
      'params': instance.params,
      'id': instance.id,
      'whois': instance.whois,
    };

WhoIsLoungeResponseBodyPart _$WhoIsLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return WhoIsLoungeResponseBodyPart(
    account: json['account'] as String,
    channels: json['channels'] as String,
    hostname: json['hostname'] as String,
    ident: json['ident'] as String,
    idle: json['idle'] as String,
    idleTime: json['idleTime'] as int,
    logonTime: json['logonTime'] as int,
    logon: json['logon'] as String,
    nick: json['nick'] as String,
    real_name: json['real_name'] as String,
    secure: json['secure'] as bool,
    server: json['server'] as String,
    serverInfo: json['serverInfo'] as String,
  );
}

Map<String, dynamic> _$WhoIsLoungeResponseBodyPartToJson(
        WhoIsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'account': instance.account,
      'channels': instance.channels,
      'hostname': instance.hostname,
      'ident': instance.ident,
      'idle': instance.idle,
      'idleTime': instance.idleTime,
      'logonTime': instance.logonTime,
      'logon': instance.logon,
      'nick': instance.nick,
      'real_name': instance.real_name,
      'secure': instance.secure,
      'server': instance.server,
      'serverInfo': instance.serverInfo,
    };

MsgFromLoungeResponseBodyPart _$MsgFromLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return MsgFromLoungeResponseBodyPart(
    json['id'] as int,
    json['mode'] as String,
    json['nick'] as String,
  );
}

Map<String, dynamic> _$MsgFromLoungeResponseBodyPartToJson(
        MsgFromLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'id': instance.id,
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
    json['isCollapsed'] as bool,
    json['isJoinChannelShown'] as bool,
    json['nick'] as String,
    json['username'] as String,
    json['realname'] as String,
    json['commands'] as List,
    (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : ChannelLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['serverOptions'] == null
        ? null
        : ServerOptionsLoungeResponseBodyPart.fromJson(
            json['serverOptions'] as Map<String, dynamic>),
    json['status'] == null
        ? null
        : NetworkStatusLoungeResponseBody.fromJson(
            json['status'] as Map<String, dynamic>),
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
      'isCollapsed': instance.isCollapsed,
      'isJoinChannelShown': instance.isJoinChannelShown,
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
    json['key'] as String,
    json['pendingMessage'] as String,
    (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : MsgLoungeResponseBody.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['inputHistory'] as String,
    json['inputHistoryPosition'] as int,
    json['id'] as int,
    json['moreHistoryAvailable'] as bool,
    json['historyLoading'] as bool,
    json['editTopic'] as bool,
    json['scrolledToBottom'] as bool,
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
      'key': instance.key,
      'pendingMessage': instance.pendingMessage,
      'messages': instance.messages,
      'inputHistory': instance.inputHistory,
      'inputHistoryPosition': instance.inputHistoryPosition,
      'id': instance.id,
      'moreHistoryAvailable': instance.moreHistoryAvailable,
      'historyLoading': instance.historyLoading,
      'editTopic': instance.editTopic,
      'scrolledToBottom': instance.scrolledToBottom,
      'topic': instance.topic,
      'state': instance.state,
      'firstUnread': instance.firstUnread,
      'unread': instance.unread,
      'highlight': instance.highlight,
      'users': instance.users,
    };
