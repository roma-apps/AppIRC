// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagePreviewToggleLoungeResponseBody
    _$MessagePreviewToggleLoungeResponseBodyFromJson(
        Map<String, dynamic> json) {
  return MessagePreviewToggleLoungeResponseBody(
    json['target'] as int,
    json['msgId'] as int,
    json['link'] as String,
    json['shown'] as bool,
  );
}

Map<String, dynamic> _$MessagePreviewToggleLoungeResponseBodyToJson(
        MessagePreviewToggleLoungeResponseBody instance) =>
    <String, dynamic>{
      'target': instance.target,
      'msgId': instance.msgId,
      'link': instance.link,
      'shown': instance.shown,
    };

MoreLoungeResponseBody _$MoreLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MoreLoungeResponseBody(
    json['chan'] as int,
    (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : MsgLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['moreHistoryAvailable'] as bool,
  );
}

Map<String, dynamic> _$MoreLoungeResponseBodyToJson(
        MoreLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'messages': instance.messages,
      'moreHistoryAvailable': instance.moreHistoryAvailable,
    };

ChangelogLoungeResponseBody _$ChangelogLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChangelogLoungeResponseBody(
    json['current'],
    json['latest'],
    json['packages'],
  );
}

Map<String, dynamic> _$ChangelogLoungeResponseBodyToJson(
        ChangelogLoungeResponseBody instance) =>
    <String, dynamic>{
      'current': instance.current,
      'latest': instance.latest,
      'packages': instance.packages,
    };

SyncSortLoungeResponseBody _$SyncSortLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return SyncSortLoungeResponseBody(
    (json['order'] as List)?.map((e) => e as int)?.toList(),
    json['type'] as String,
    json['target'] as String,
  );
}

Map<String, dynamic> _$SyncSortLoungeResponseBodyToJson(
        SyncSortLoungeResponseBody instance) =>
    <String, dynamic>{
      'order': instance.order,
      'type': instance.type,
      'target': instance.target,
    };

SettingsNewLoungeResponseBody _$SettingsNewLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return SettingsNewLoungeResponseBody(
    json['name'] as String,
    json['value'],
  );
}

Map<String, dynamic> _$SettingsNewLoungeResponseBodyToJson(
        SettingsNewLoungeResponseBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

SessionsListLoungeResponseBodyPart _$SessionsListLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return SessionsListLoungeResponseBodyPart(
    json['current'] as bool,
    json['active'] as int,
    json['lastUse'] as int,
    json['ip'] as String,
    json['agent'] as String,
    json['token'] as String,
  );
}

Map<String, dynamic> _$SessionsListLoungeResponseBodyPartToJson(
        SessionsListLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'current': instance.current,
      'active': instance.active,
      'lastUse': instance.lastUse,
      'ip': instance.ip,
      'agent': instance.agent,
      'token': instance.token,
    };

MsgLoungeResponseBody _$MsgLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgLoungeResponseBody(
    json['chan'] as int,
    json['highlight'] as int,
    json['unread'] as int,
    json['msg'] == null
        ? null
        : MsgLoungeResponseBodyPart.fromJson(
            json['msg'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MsgLoungeResponseBodyToJson(
        MsgLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'highlight': instance.highlight,
      'unread': instance.unread,
      'msg': instance.msg,
    };

MsgSpecialLoungeResponseBody _$MsgSpecialLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgSpecialLoungeResponseBody(
    json['chan'] as int,
    json['data'],
  );
}

Map<String, dynamic> _$MsgSpecialLoungeResponseBodyToJson(
        MsgSpecialLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'data': instance.data,
    };

DefaultsLoungeResponseBodyPart _$DefaultsLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return DefaultsLoungeResponseBodyPart(
    json['host'] as String,
    json['port'] as int,
    json['join'] as String,
    json['name'] as String,
    json['nick'] as String,
    json['password'] as String,
    json['realname'] as String,
    json['rejectUnauthorized'] as bool,
    json['tls'] as bool,
    json['username'] as String,
  );
}

Map<String, dynamic> _$DefaultsLoungeResponseBodyPartToJson(
        DefaultsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'host': instance.host,
      'port': instance.port,
      'join': instance.join,
      'name': instance.name,
      'nick': instance.nick,
      'password': instance.password,
      'realname': instance.realname,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'tls': instance.tls,
      'username': instance.username,
    };

ConfigurationLoungeResponseBody _$ConfigurationLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ConfigurationLoungeResponseBody(
    json['defaultTheme'] as String,
    json['defaults'] == null
        ? null
        : DefaultsLoungeResponseBodyPart.fromJson(
            json['defaults'] as Map<String, dynamic>),
    json['displayNetwork'] as bool,
    json['fileUpload'] as bool,
    json['ldapEnabled'] as bool,
    json['lockNetwork'] as bool,
    json['prefetch'] as bool,
    json['public'] as bool,
    json['useHexIp'] as bool,
    json['themes'] as List,
    json['fileUploadMaxFileSize'] as int,
    json['gitCommit'] as String,
    json['version'] as String,
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
      'themes': instance.themes,
      'fileUploadMaxFileSize': instance.fileUploadMaxFileSize,
      'gitCommit': instance.gitCommit,
      'version': instance.version,
    };

AuthLoungeResponseBody _$AuthLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return AuthLoungeResponseBody(
    json['serverHash'] as int,
    json['success'] as bool,
  );
}

Map<String, dynamic> _$AuthLoungeResponseBodyToJson(
        AuthLoungeResponseBody instance) =>
    <String, dynamic>{
      'success': instance.success,
      'serverHash': instance.serverHash,
    };

JoinLoungeResponseBody _$JoinLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return JoinLoungeResponseBody(
    json['chan'] == null
        ? null
        : ChannelLoungeResponseBodyPart.fromJson(
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

PartLoungeResponseBody _$PartLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return PartLoungeResponseBody(
    json['chan'] as int,
  );
}

Map<String, dynamic> _$PartLoungeResponseBodyToJson(
        PartLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
    };

QuitLoungeResponseBody _$QuitLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return QuitLoungeResponseBody(
    json['network'] as String,
  );
}

Map<String, dynamic> _$QuitLoungeResponseBodyToJson(
        QuitLoungeResponseBody instance) =>
    <String, dynamic>{
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

MsgLoungeResponseBodyPart _$MsgLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return MsgLoungeResponseBodyPart(
    json['from'] == null
        ? null
        : MsgUserLoungeResponseBodyPart.fromJson(
            json['from'] as Map<String, dynamic>),
    json['target'] == null
        ? null
        : MsgUserLoungeResponseBodyPart.fromJson(
            json['target'] as Map<String, dynamic>),
    json['command'] as String,
    json['type'] as String,
    json['time'] as String,
    json['new_nick'] as String,
    json['new_host'] as String,
    json['new_ident'] as String,
    json['text'] as String,
    json['ctcpMessage'] as String,
    json['hostmask'] as String,
    json['self'] as bool,
    json['highlight'] as bool,
    json['showInActive'] as bool,
    (json['users'] as List)?.map((e) => e as String)?.toList(),
    (json['previews'] as List)
        ?.map((e) => e == null
            ? null
            : MsgPreviewLoungeResponseBodyPart.fromJson(
                e as Map<String, dynamic>))
        ?.toList(),
    (json['params'] as List)?.map((e) => e as String)?.toList(),
    json['id'] as int,
    json['whois'] == null
        ? null
        : WhoIsLoungeResponseBodyPart.fromJson(
            json['whois'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MsgLoungeResponseBodyPartToJson(
        MsgLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'from': instance.from,
      'target': instance.target,
      'command': instance.command,
      'type': instance.type,
      'time': instance.time,
      'new_nick': instance.new_nick,
      'new_host': instance.new_host,
      'new_ident': instance.new_ident,
      'text': instance.text,
      'ctcpMessage': instance.ctcpMessage,
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
    actual_hostname: json['actual_hostname'] as String,
    actual_ip: json['actual_ip'] as String,
    nick: json['nick'] as String,
    real_name: json['real_name'] as String,
    secure: json['secure'] as bool,
    server: json['server'] as String,
    server_info: json['server_info'] as String,
  );
}

Map<String, dynamic> _$WhoIsLoungeResponseBodyPartToJson(
        WhoIsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'account': instance.account,
      'channels': instance.channels,
      'hostname': instance.hostname,
      'ident': instance.ident,
      'actual_hostname': instance.actual_hostname,
      'actual_ip': instance.actual_ip,
      'idle': instance.idle,
      'idleTime': instance.idleTime,
      'logonTime': instance.logonTime,
      'logon': instance.logon,
      'nick': instance.nick,
      'real_name': instance.real_name,
      'secure': instance.secure,
      'server': instance.server,
      'server_info': instance.server_info,
    };

MsgUserLoungeResponseBodyPart _$MsgUserLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return MsgUserLoungeResponseBodyPart(
    json['id'] as int,
    json['mode'] as String,
    json['nick'] as String,
  );
}

Map<String, dynamic> _$MsgUserLoungeResponseBodyPartToJson(
        MsgUserLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mode': instance.mode,
      'nick': instance.nick,
    };

MsgPreviewLoungeResponseBodyPart _$MsgPreviewLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return MsgPreviewLoungeResponseBodyPart(
    json['head'] as String,
    json['body'] as String,
    json['canDisplay'] as bool,
    json['shown'] as bool,
    json['link'] as String,
    json['thumb'] as String,
    json['media'] as String,
    json['mediaType'] as String,
    json['type'] as String,
  );
}

Map<String, dynamic> _$MsgPreviewLoungeResponseBodyPartToJson(
        MsgPreviewLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'head': instance.head,
      'body': instance.body,
      'canDisplay': instance.canDisplay,
      'shown': instance.shown,
      'link': instance.link,
      'thumb': instance.thumb,
      'media': instance.media,
      'mediaType': instance.mediaType,
      'type': instance.type,
    };

MsgPreviewLoungeResponseBody _$MsgPreviewLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return MsgPreviewLoungeResponseBody(
    json['id'] as int,
    json['chan'] as int,
    json['preview'] == null
        ? null
        : MsgPreviewLoungeResponseBodyPart.fromJson(
            json['preview'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MsgPreviewLoungeResponseBodyToJson(
        MsgPreviewLoungeResponseBody instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chan': instance.chan,
      'preview': instance.preview,
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
            : NetworkLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['pushSubscription'] == null
        ? null
        : PushSubscriptionLoungeResponseBodyPart.fromJson(
            json['pushSubscription'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$InitLoungeResponseBodyToJson(
        InitLoungeResponseBody instance) =>
    <String, dynamic>{
      'active': instance.active,
      'applicationServerKey': instance.applicationServerKey,
      'token': instance.token,
      'networks': instance.networks,
      'pushSubscription': instance.pushSubscription,
    };

PushSubscriptionLoungeResponseBodyPart
    _$PushSubscriptionLoungeResponseBodyPartFromJson(
        Map<String, dynamic> json) {
  return PushSubscriptionLoungeResponseBodyPart(
    json['agent'] as String,
    json['ip'] as String,
    json['lastUse'] as int,
  );
}

Map<String, dynamic> _$PushSubscriptionLoungeResponseBodyPartToJson(
        PushSubscriptionLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'agent': instance.agent,
      'ip': instance.ip,
      'lastUse': instance.lastUse,
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

TextSpecialMessageLoungeResponseBodyPart
    _$TextSpecialMessageLoungeResponseBodyPartFromJson(
        Map<String, dynamic> json) {
  return TextSpecialMessageLoungeResponseBodyPart(
    json['text'] as String,
  );
}

Map<String, dynamic> _$TextSpecialMessageLoungeResponseBodyPartToJson(
        TextSpecialMessageLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'text': instance.text,
    };

ChannelListItemSpecialMessageLoungeResponseBodyPart
    _$ChannelListItemSpecialMessageLoungeResponseBodyPartFromJson(
        Map<String, dynamic> json) {
  return ChannelListItemSpecialMessageLoungeResponseBodyPart(
    json['channel'] as String,
    json['topic'] as String,
    json['num_users'] as int,
  );
}

Map<String, dynamic>
    _$ChannelListItemSpecialMessageLoungeResponseBodyPartToJson(
            ChannelListItemSpecialMessageLoungeResponseBodyPart instance) =>
        <String, dynamic>{
          'channel': instance.channel,
          'topic': instance.topic,
          'num_users': instance.num_users,
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

NetworkLoungeResponseBody _$NetworkLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NetworkLoungeResponseBody(
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : NetworkLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NetworkLoungeResponseBodyToJson(
        NetworkLoungeResponseBody instance) =>
    <String, dynamic>{
      'networks': instance.networks,
    };

NetworkLoungeResponseBodyPart _$NetworkLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return NetworkLoungeResponseBodyPart(
    json['uuid'] as String,
    json['name'] as String,
    json['host'] as String,
    json['port'] as int,
    json['tls'] as bool,
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
            : ChannelLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
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

Map<String, dynamic> _$NetworkLoungeResponseBodyPartToJson(
        NetworkLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'host': instance.host,
      'port': instance.port,
      'tls': instance.tls,
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

ChannelLoungeResponseBodyPart _$ChannelLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return ChannelLoungeResponseBodyPart(
    json['name'] as String,
    json['type'] as String,
    json['key'] as String,
    json['pendingMessage'] as String,
    (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : MsgLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
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
    (json['users'] as List)
        ?.map((e) => e == null
            ? null
            : UserLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChannelLoungeResponseBodyPartToJson(
        ChannelLoungeResponseBodyPart instance) =>
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
