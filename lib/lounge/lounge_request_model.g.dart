// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushFCMTokenLoungeJsonRequest _$PushFCMTokenLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return PushFCMTokenLoungeJsonRequest(
    fcmToken: json['token'] as String,
  );
}

Map<String, dynamic> _$PushFCMTokenLoungeJsonRequestToJson(
        PushFCMTokenLoungeJsonRequest instance) =>
    <String, dynamic>{
      'token': instance.fcmToken,
    };

InputLoungeJsonRequest _$InputLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return InputLoungeJsonRequest(
    targetChannelRemoteId: json['target'] as int,
    text: json['text'] as String,
  );
}

Map<String, dynamic> _$InputLoungeJsonRequestToJson(
        InputLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.targetChannelRemoteId,
      'text': instance.text,
    };

MoreLoungeJsonRequest _$MoreLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return MoreLoungeJsonRequest(
    targetChannelRemoteId: json['target'] as int,
    lastMessageRemoteId: json['lastId'] as int,
  );
}

Map<String, dynamic> _$MoreLoungeJsonRequestToJson(
        MoreLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.targetChannelRemoteId,
      'lastId': instance.lastMessageRemoteId,
    };

MsgPreviewToggleLoungeJsonRequest _$MsgPreviewToggleLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return MsgPreviewToggleLoungeJsonRequest(
    targetChannelRemoteId: json['target'] as int,
    messageRemoteId: json['msgId'] as int,
    link: json['link'] as String,
    shown: json['shown'] as bool,
  );
}

Map<String, dynamic> _$MsgPreviewToggleLoungeJsonRequestToJson(
    MsgPreviewToggleLoungeJsonRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('target', instance.targetChannelRemoteId);
  writeNotNull('msgId', instance.messageRemoteId);
  writeNotNull('link', instance.link);
  writeNotNull('shown', instance.shown);
  return val;
}

NamesLoungeJsonRequest _$NamesLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return NamesLoungeJsonRequest(
    targetChannelRemoteId: json['target'] as int,
  );
}

Map<String, dynamic> _$NamesLoungeJsonRequestToJson(
        NamesLoungeJsonRequest instance) =>
    <String, dynamic>{
      'target': instance.targetChannelRemoteId,
    };

SignUpLoungeJsonRequest _$SignUpLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return SignUpLoungeJsonRequest(
    user: json['user'] as String,
    password: json['password'] as String,
  );
}

Map<String, dynamic> _$SignUpLoungeJsonRequestToJson(
        SignUpLoungeJsonRequest instance) =>
    <String, dynamic>{
      'user': instance.user,
      'password': instance.password,
    };

AuthPerformLoungeJsonRequest _$AuthPerformLoungeJsonRequestFromJson(
    Map<String, dynamic> json) {
  return AuthPerformLoungeJsonRequest(
    user: json['user'] as String,
    password: json['password'] as String,
    token: json['token'] as String,
    lastMessageRemoteId: json['lastMessage'] as int,
    openChannelRemoteId: json['openChannel'] as int,
    hasConfig: json['hasConfig'] as bool,
  );
}

Map<String, dynamic> _$AuthPerformLoungeJsonRequestToJson(
    AuthPerformLoungeJsonRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('user', instance.user);
  writeNotNull('password', instance.password);
  writeNotNull('token', instance.token);
  writeNotNull('lastMessage', instance.lastMessageRemoteId);
  writeNotNull('openChannel', instance.openChannelRemoteId);
  writeNotNull('hasConfig', instance.hasConfig);
  return val;
}

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
    NetworkEditLoungeJsonRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('host', instance.host);
  writeNotNull('name', instance.name);
  writeNotNull('nick', instance.nick);
  writeNotNull('port', instance.port);
  writeNotNull('realname', instance.realname);
  writeNotNull('password', instance.password);
  writeNotNull('rejectUnauthorized', instance.rejectUnauthorized);
  writeNotNull('tls', instance.tls);
  writeNotNull('username', instance.username);
  writeNotNull('commands', instance.commands);
  writeNotNull('uuid', instance.uuid);
  return val;
}

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
    NetworkNewLoungeJsonRequest instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('host', instance.host);
  writeNotNull('name', instance.name);
  writeNotNull('nick', instance.nick);
  writeNotNull('port', instance.port);
  writeNotNull('realname', instance.realname);
  writeNotNull('password', instance.password);
  writeNotNull('rejectUnauthorized', instance.rejectUnauthorized);
  writeNotNull('tls', instance.tls);
  writeNotNull('username', instance.username);
  writeNotNull('commands', instance.commands);
  val['join'] = instance.join;
  return val;
}
