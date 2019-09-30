// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatNetworkServerPreferences _$ChatNetworkServerPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkServerPreferences(
    name: json['name'] as String,
    serverHost: json['serverHost'] as String,
    serverPort: json['serverPort'] as String,
    useTls: json['useTls'] as bool,
    useOnlyTrustedCertificates: json['useOnlyTrustedCertificates'] as bool,
    enabled: json['enabled'] as bool,
    visible: json['visible'] as bool,
  );
}

Map<String, dynamic> _$ChatNetworkServerPreferencesToJson(
        ChatNetworkServerPreferences instance) =>
    <String, dynamic>{
      'name': instance.name,
      'serverHost': instance.serverHost,
      'serverPort': instance.serverPort,
      'useTls': instance.useTls,
      'useOnlyTrustedCertificates': instance.useOnlyTrustedCertificates,
      'visible': instance.visible,
      'enabled': instance.enabled,
    };

ChatNetworkUserPreferences _$ChatNetworkUserPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkUserPreferences(
    nickname: json['nickname'] as String,
    password: json['password'] as String,
    commands: json['commands'] as String,
    realName: json['realName'] as String,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$ChatNetworkUserPreferencesToJson(
        ChatNetworkUserPreferences instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'username': instance.username,
      'password': instance.password,
      'realName': instance.realName,
      'commands': instance.commands,
    };

ChatNetworkChannelPreferences _$ChatNetworkChannelPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkChannelPreferences(
    json['localId'] as int,
    json['password'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$ChatNetworkChannelPreferencesToJson(
        ChatNetworkChannelPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'name': instance.name,
      'password': instance.password,
    };

ChatNetworkPreferences _$ChatNetworkPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkPreferences(
    json['networkConnectionPreferences'] == null
        ? null
        : ChatNetworkConnectionPreferences.fromJson(
            json['networkConnectionPreferences'] as Map<String, dynamic>),
    (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : ChatNetworkChannelPreferences.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChatNetworkPreferencesToJson(
        ChatNetworkPreferences instance) =>
    <String, dynamic>{
      'networkConnectionPreferences': instance.networkConnectionPreferences,
      'channels': instance.channels,
    };

ChatNetworkConnectionPreferences _$ChatNetworkConnectionPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkConnectionPreferences(
    serverPreferences: json['serverPreferences'] == null
        ? null
        : ChatNetworkServerPreferences.fromJson(
            json['serverPreferences'] as Map<String, dynamic>),
    userPreferences: json['userPreferences'] == null
        ? null
        : ChatNetworkUserPreferences.fromJson(
            json['userPreferences'] as Map<String, dynamic>),
    localId: json['localId'] as int,
  );
}

Map<String, dynamic> _$ChatNetworkConnectionPreferencesToJson(
        ChatNetworkConnectionPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'serverPreferences': instance.serverPreferences,
      'userPreferences': instance.userPreferences,
    };
