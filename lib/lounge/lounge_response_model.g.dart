// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagePreviewToggleLoungeResponseBody
    _$MessagePreviewToggleLoungeResponseBodyFromJson(
        Map<String, dynamic> json) {
  return MessagePreviewToggleLoungeResponseBody(
    target: json['target'] as int,
    msgId: json['msgId'] as int,
    link: json['link'] as String,
    shown: json['shown'] as bool,
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
    chan: json['chan'] as int,
    messages: (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : MsgLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    totalMessages: json['totalMessages'] as int,
  );
}

Map<String, dynamic> _$MoreLoungeResponseBodyToJson(
        MoreLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'messages': instance.messages,
      'totalMessages': instance.totalMessages,
    };

ChangelogLoungeResponseBody _$ChangelogLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChangelogLoungeResponseBody(
    current: json['current'],
    latest: json['latest'],
    packages: json['packages'],
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
    order: (json['order'] as List)?.map((e) => e as int)?.toList(),
    type: json['type'] as String,
    target: json['target'] as String,
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
    name: json['name'] as String,
    value: json['value'],
  );
}

Map<String, dynamic> _$SettingsNewLoungeResponseBodyToJson(
        SettingsNewLoungeResponseBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

SettingsAllLoungeResponseBody _$SettingsAllLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return SettingsAllLoungeResponseBody(
    advanced: json['advanced'] as bool,
    autocomplete: json['autocomplete'] as bool,
    awayMessage: json['awayMessage'] as String,
    coloredNicks: json['coloredNicks'] as bool,
    highlightExceptions: json['highlightExceptions'] as String,
    highlights: json['highlights'] as String,
    links: json['links'] as bool,
    media: json['media'] as bool,
    motd: json['motd'] as bool,
    nickPostfix: json['nickPostfix'] as String,
    notifyAllMessages: json['notifyAllMessages'] as bool,
    showSeconds: json['showSeconds'] as bool,
    statusMessages: json['statusMessages'] as String,
    theme: json['theme'] as String,
    uploadCanvas: json['uploadCanvas'] as bool,
    use12hClock: json['use12hClock'] as bool,
    userStyles: json['userStyles'] as String,
  );
}

Map<String, dynamic> _$SettingsAllLoungeResponseBodyToJson(
        SettingsAllLoungeResponseBody instance) =>
    <String, dynamic>{
      'advanced': instance.advanced,
      'autocomplete': instance.autocomplete,
      'awayMessage': instance.awayMessage,
      'coloredNicks': instance.coloredNicks,
      'highlightExceptions': instance.highlightExceptions,
      'highlights': instance.highlights,
      'links': instance.links,
      'media': instance.media,
      'motd': instance.motd,
      'nickPostfix': instance.nickPostfix,
      'notifyAllMessages': instance.notifyAllMessages,
      'showSeconds': instance.showSeconds,
      'statusMessages': instance.statusMessages,
      'theme': instance.theme,
      'uploadCanvas': instance.uploadCanvas,
      'use12hClock': instance.use12hClock,
      'userStyles': instance.userStyles,
    };

SessionsListLoungeResponseBodyPart _$SessionsListLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return SessionsListLoungeResponseBodyPart(
    current: json['current'] as bool,
    active: json['active'] as int,
    lastUse: json['lastUse'] as int,
    ip: json['ip'] as String,
    agent: json['agent'] as String,
    token: json['token'] as String,
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
    chan: json['chan'] as int,
    highlight: json['highlight'] as int,
    unread: json['unread'] as int,
    msg: json['msg'] == null
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
    chan: json['chan'] as int,
    data: json['data'],
  );
}

Map<String, dynamic> _$MsgSpecialLoungeResponseBodyToJson(
        MsgSpecialLoungeResponseBody instance) =>
    <String, dynamic>{
      'chan': instance.chan,
      'data': instance.data,
    };

ConfigurationDefaultsLoungeResponseBodyPart
    _$ConfigurationDefaultsLoungeResponseBodyPartFromJson(
        Map<String, dynamic> json) {
  return ConfigurationDefaultsLoungeResponseBodyPart(
    name: json['name'] as String,
    host: json['host'] as String,
    port: json['port'] as int,
    password: json['password'] as String,
    tls: json['tls'] as bool,
    rejectUnauthorized: json['rejectUnauthorized'] as bool,
    nick: json['nick'] as String,
    username: json['username'] as String,
    realname: json['realname'] as String,
    join: json['join'] as String,
    leaveMessage: json['leaveMessage'] as String,
    sasl: json['sasl'] as String,
    saslAccount: json['saslAccount'] as String,
    saslPassword: json['saslPassword'] as String,
  );
}

Map<String, dynamic> _$ConfigurationDefaultsLoungeResponseBodyPartToJson(
        ConfigurationDefaultsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'name': instance.name,
      'host': instance.host,
      'port': instance.port,
      'password': instance.password,
      'tls': instance.tls,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'nick': instance.nick,
      'username': instance.username,
      'realname': instance.realname,
      'join': instance.join,
      'leaveMessage': instance.leaveMessage,
      'sasl': instance.sasl,
      'saslAccount': instance.saslAccount,
      'saslPassword': instance.saslPassword,
    };

ConfigurationLoungeResponseBody _$ConfigurationLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ConfigurationLoungeResponseBody(
    public: json['public'] as bool,
    useHexIp: json['useHexIp'] as bool,
    prefetch: json['prefetch'] as bool,
    fileUpload: json['fileUpload'] as bool,
    ldapEnabled: json['ldapEnabled'] as bool,
    defaults: json['defaults'] == null
        ? null
        : ConfigurationDefaultsLoungeResponseBodyPart.fromJson(
            json['defaults'] as Map<String, dynamic>),
    isUpdateAvailable: json['isUpdateAvailable'] as bool,
    applicationServerKey: json['applicationServerKey'] as String,
    version: json['version'] as String,
    gitCommit: json['gitCommit'] as String,
    lockNetwork: json['lockNetwork'] as bool,
    themes: json['themes'] as List,
    defaultTheme: json['defaultTheme'] as String,
    fileUploadMaxFileSize: json['fileUploadMaxFileSize'] as int,
    signUp: json['signUp'] as bool ?? false,
    fcmPushEnabled: json['fcmPushEnabled'] as bool ?? false,
  );
}

Map<String, dynamic> _$ConfigurationLoungeResponseBodyToJson(
        ConfigurationLoungeResponseBody instance) =>
    <String, dynamic>{
      'public': instance.public,
      'lockNetwork': instance.lockNetwork,
      'useHexIp': instance.useHexIp,
      'prefetch': instance.prefetch,
      'fileUpload': instance.fileUpload,
      'ldapEnabled': instance.ldapEnabled,
      'defaults': instance.defaults?.toJson(),
      'isUpdateAvailable': instance.isUpdateAvailable,
      'applicationServerKey': instance.applicationServerKey,
      'version': instance.version,
      'gitCommit': instance.gitCommit,
      'themes': instance.themes,
      'defaultTheme': instance.defaultTheme,
      'fileUploadMaxFileSize': instance.fileUploadMaxFileSize,
      'signUp': instance.signUp,
      'fcmPushEnabled': instance.fcmPushEnabled,
    };

SignedUpLoungeResponseBody _$SignedUpLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return SignedUpLoungeResponseBody(
    success: json['success'] as bool,
    errorType: json['errorType'] as String,
  );
}

Map<String, dynamic> _$SignedUpLoungeResponseBodyToJson(
        SignedUpLoungeResponseBody instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errorType': instance.errorType,
    };

JoinLoungeResponseBody _$JoinLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return JoinLoungeResponseBody(
    chan: json['chan'] == null
        ? null
        : ChannelLoungeResponseBodyPart.fromJson(
            json['chan'] as Map<String, dynamic>),
    index: json['index'] as int,
    network: json['network'] as String,
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
    chan: json['chan'] as int,
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
    network: json['network'] as String,
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
    connected: json['connected'] as bool,
    network: json['network'] as String,
    secure: json['secure'] as bool,
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
    network: json['network'] as String,
    serverOptions: json['serverOptions'] == null
        ? null
        : NetworkServerOptionsLoungeResponseBodyPart.fromJson(
            json['serverOptions'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$NetworkOptionsLoungeResponseBodyToJson(
        NetworkOptionsLoungeResponseBody instance) =>
    <String, dynamic>{
      'network': instance.network,
      'serverOptions': instance.serverOptions,
    };

NetworkServerOptionsLoungeResponseBodyPart
    _$NetworkServerOptionsLoungeResponseBodyPartFromJson(
        Map<String, dynamic> json) {
  return NetworkServerOptionsLoungeResponseBodyPart(
    chanTypes: (json['CHANTYPES'] as List)?.map((e) => e as String)?.toList(),
    network: json['NETWORK'] as String,
    prefix: (json['PREFIX'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$NetworkServerOptionsLoungeResponseBodyPartToJson(
        NetworkServerOptionsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'CHANTYPES': instance.chanTypes,
      'NETWORK': instance.network,
      'PREFIX': instance.prefix,
    };

ChannelStateLoungeResponseBody _$ChannelStateLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return ChannelStateLoungeResponseBody(
    chan: json['chan'] as int,
    state: json['state'] as int,
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
    chan: json['chan'] as int,
    unread: json['unread'] as int,
    highlight: json['highlight'] as int,
    msg: json['msg'],
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
    network: json['network'] as String,
    nick: json['nick'] as String,
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
    from: json['from'] == null
        ? null
        : MsgUserLoungeResponseBodyPart.fromJson(
            json['from'] as Map<String, dynamic>),
    target: json['target'] == null
        ? null
        : MsgUserLoungeResponseBodyPart.fromJson(
            json['target'] as Map<String, dynamic>),
    command: json['command'] as String,
    type: json['type'] as String,
    time: json['time'] as String,
    newNick: json['new_nick'] as String,
    newHost: json['new_host'] as String,
    newIdent: json['new_ident'] as String,
    text: json['text'] as String,
    ctcpMessage: json['ctcpMessage'] as String,
    hostmask: json['hostmask'] as String,
    self: json['self'] as bool,
    highlight: json['highlight'] as bool,
    showInActive: json['showInActive'] as bool,
    users: (json['users'] as List)?.map((e) => e as String)?.toList(),
    previews: (json['previews'] as List)
        ?.map((e) => e == null
            ? null
            : MsgPreviewLoungeResponseBodyPart.fromJson(
                e as Map<String, dynamic>))
        ?.toList(),
    params: (json['params'] as List)?.map((e) => e as String)?.toList(),
    id: json['id'] as int,
    whois: json['whois'] == null
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
      'new_nick': instance.newNick,
      'new_host': instance.newHost,
      'new_ident': instance.newIdent,
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
    actualHostname: json['actual_hostname'] as String,
    actualIp: json['actual_ip'] as String,
    nick: json['nick'] as String,
    realName: json['real_name'] as String,
    secure: json['secure'] as bool,
    server: json['server'] as String,
    serverInfo: json['server_info'] as String,
  );
}

Map<String, dynamic> _$WhoIsLoungeResponseBodyPartToJson(
        WhoIsLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'account': instance.account,
      'channels': instance.channels,
      'hostname': instance.hostname,
      'ident': instance.ident,
      'actual_hostname': instance.actualHostname,
      'actual_ip': instance.actualIp,
      'idle': instance.idle,
      'idleTime': instance.idleTime,
      'logonTime': instance.logonTime,
      'logon': instance.logon,
      'nick': instance.nick,
      'real_name': instance.realName,
      'secure': instance.secure,
      'server': instance.server,
      'server_info': instance.serverInfo,
    };

MsgUserLoungeResponseBodyPart _$MsgUserLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return MsgUserLoungeResponseBodyPart(
    id: json['id'] as int,
    mode: json['mode'] as String,
    nick: json['nick'] as String,
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
    head: json['head'] as String,
    body: json['body'] as String,
    canDisplay: json['canDisplay'] as bool,
    shown: json['shown'] as bool,
    link: json['link'] as String,
    thumb: json['thumb'] as String,
    media: json['media'] as String,
    mediaType: json['mediaType'] as String,
    type: json['type'] as String,
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
    id: json['id'] as int,
    chan: json['chan'] as int,
    preview: json['preview'] == null
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
    active: json['active'] as int,
    networks: (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : NetworkLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    token: json['token'] as String,
    applicationServerKey: json['applicationServerKey'] as String,
    pushSubscription: json['pushSubscription'] == null
        ? null
        : InitPushSubscriptionLoungeResponseBodyPart.fromJson(
            json['pushSubscription'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$InitLoungeResponseBodyToJson(
        InitLoungeResponseBody instance) =>
    <String, dynamic>{
      'active': instance.active,
      'networks': instance.networks,
      'token': instance.token,
      'applicationServerKey': instance.applicationServerKey,
      'pushSubscription': instance.pushSubscription,
    };

InitPushSubscriptionLoungeResponseBodyPart
    _$InitPushSubscriptionLoungeResponseBodyPartFromJson(
        Map<String, dynamic> json) {
  return InitPushSubscriptionLoungeResponseBodyPart(
    agent: json['agent'] as String,
    ip: json['ip'] as String,
    lastUse: json['lastUse'] as int,
  );
}

Map<String, dynamic> _$InitPushSubscriptionLoungeResponseBodyPartToJson(
        InitPushSubscriptionLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'agent': instance.agent,
      'ip': instance.ip,
      'lastUse': instance.lastUse,
    };

NamesLoungeResponseBody _$NamesLoungeResponseBodyFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeResponseBody(
    id: json['id'] as int,
    users: (json['users'] as List)
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
    chan: json['chan'] as int,
    topic: json['topic'] as String,
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
    text: json['text'] as String,
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
    channel: json['channel'] as String,
    topic: json['topic'] as String,
    numUsers: json['num_users'] as int,
  );
}

Map<String, dynamic>
    _$ChannelListItemSpecialMessageLoungeResponseBodyPartToJson(
            ChannelListItemSpecialMessageLoungeResponseBodyPart instance) =>
        <String, dynamic>{
          'channel': instance.channel,
          'topic': instance.topic,
          'num_users': instance.numUsers,
        };

UserLoungeResponseBodyPart _$UserLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return UserLoungeResponseBodyPart(
    lastMessage: json['lastMessage'] as int,
    mode: json['mode'] as String,
    nick: json['nick'] as String,
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
    networks: (json['networks'] as List)
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
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    host: json['host'] as String,
    port: json['port'] as int,
    tls: json['tls'] as bool,
    rejectUnauthorized: json['rejectUnauthorized'] as bool,
    isCollapsed: json['isCollapsed'] as bool,
    isJoinChannelShown: json['isJoinChannelShown'] as bool,
    nick: json['nick'] as String,
    username: json['username'] as String,
    realname: json['realname'] as String,
    commands: json['commands'] as List,
    channels: (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : ChannelLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    serverOptions: json['serverOptions'] == null
        ? null
        : NetworkServerOptionsLoungeResponseBodyPart.fromJson(
            json['serverOptions'] as Map<String, dynamic>),
    status: json['status'] == null
        ? null
        : NetworkStatusLoungeResponseBody.fromJson(
            json['status'] as Map<String, dynamic>),
    leaveMessage: json['leaveMessage'] as String,
    hasSTSPolicy: json['hasSTSPolicy'] as bool,
    sasl: json['sasl'] as String,
    saslAccount: json['saslAccount'] as String,
    saslPassword: json['saslPassword'] as String,
    password: json['password'] as String,
  );
}

Map<String, dynamic> _$NetworkLoungeResponseBodyPartToJson(
        NetworkLoungeResponseBodyPart instance) =>
    <String, dynamic>{
      'commands': instance.commands,
      'hasSTSPolicy': instance.hasSTSPolicy,
      'host': instance.host,
      'leaveMessage': instance.leaveMessage,
      'name': instance.name,
      'nick': instance.nick,
      'password': instance.password,
      'port': instance.port,
      'realname': instance.realname,
      'rejectUnauthorized': instance.rejectUnauthorized,
      'sasl': instance.sasl,
      'saslAccount': instance.saslAccount,
      'saslPassword': instance.saslPassword,
      'tls': instance.tls,
      'username': instance.username,
      'uuid': instance.uuid,
      'isCollapsed': instance.isCollapsed,
      'isJoinChannelShown': instance.isJoinChannelShown,
      'channels': instance.channels,
      'serverOptions': instance.serverOptions,
      'status': instance.status,
    };

ChannelLoungeResponseBodyPart _$ChannelLoungeResponseBodyPartFromJson(
    Map<String, dynamic> json) {
  return ChannelLoungeResponseBodyPart(
    name: json['name'] as String,
    type: json['type'] as String,
    key: json['key'] as String,
    pendingMessage: json['pendingMessage'] as String,
    messages: (json['messages'] as List)
        ?.map((e) => e == null
            ? null
            : MsgLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    inputHistory: json['inputHistory'] as String,
    inputHistoryPosition: json['inputHistoryPosition'] as int,
    id: json['id'] as int,
    moreHistoryAvailable: json['moreHistoryAvailable'] as bool,
    historyLoading: json['historyLoading'] as bool,
    editTopic: json['editTopic'] as bool,
    scrolledToBottom: json['scrolledToBottom'] as bool,
    topic: json['topic'] as String,
    state: json['state'] as int,
    firstUnread: json['firstUnread'] as int,
    unread: json['unread'] as int,
    highlight: json['highlight'] as int,
    users: (json['users'] as List)
        ?.map((e) => e == null
            ? null
            : UserLoungeResponseBodyPart.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    totalMessages: json['totalMessages'] as int,
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
      'totalMessages': instance.totalMessages,
    };
