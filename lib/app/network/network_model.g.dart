// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatNetworkServerPreferences _$IRCNetworkServerPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkServerPreferences(
    name: json['name'] as String,
    serverHost: json['serverHost'] as String,
    serverPort: json['serverPort'] as String,
    useTls: json['useTls'] as bool,
    useOnlyTrustedCertificates: json['useOnlyTrustedCertificates'] as bool,
  );
}

Map<String, dynamic> _$IRCNetworkServerPreferencesToJson(
        ChatNetworkServerPreferences instance) =>
    <String, dynamic>{
      'name': instance.name,
      'serverHost': instance.serverHost,
      'serverPort': instance.serverPort,
      'useTls': instance.useTls,
      'useOnlyTrustedCertificates': instance.useOnlyTrustedCertificates,
    };

ChatNetworkUserPreferences _$IRCNetworkUserPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkUserPreferences(
    nickname: json['nickname'] as String,
    password: json['password'] as String,
    realName: json['realName'] as String,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$IRCNetworkUserPreferencesToJson(
        ChatNetworkUserPreferences instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'username': instance.username,
      'password': instance.password,
      'realName': instance.realName,
    };

ChatNetworkChannelPreferences _$IRCNetworkChannelPreferencesFromJson(
    Map<String, dynamic> json) {
  return ChatNetworkChannelPreferences(
    json['localId'] as int,
    json['password'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$IRCNetworkChannelPreferencesToJson(
        ChatNetworkChannelPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'name': instance.name,
      'password': instance.password,
    };

ChatNetworkPreferences _$IRCNetworkPreferencesFromJson(
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

Map<String, dynamic> _$IRCNetworkPreferencesToJson(
        ChatNetworkPreferences instance) =>
    <String, dynamic>{
      'networkConnectionPreferences': instance.networkConnectionPreferences,
      'channels': instance.channels,
    };

ChatNetworkConnectionPreferences _$IRCNetworkConnectionPreferencesFromJson(
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

Map<String, dynamic> _$IRCNetworkConnectionPreferencesToJson(
        ChatNetworkConnectionPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'serverPreferences': instance.serverPreferences,
      'userPreferences': instance.userPreferences,
    };
