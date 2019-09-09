// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'irc_network_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IRCNetworkServerPreferences _$IRCNetworkServerPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkServerPreferences(
    name: json['name'] as String,
    serverHost: json['serverHost'] as String,
    serverPort: json['serverPort'] as String,
    useTls: json['useTls'] as bool,
    useOnlyTrustedCertificates: json['useOnlyTrustedCertificates'] as bool,
  );
}

Map<String, dynamic> _$IRCNetworkServerPreferencesToJson(
        IRCNetworkServerPreferences instance) =>
    <String, dynamic>{
      'name': instance.name,
      'serverHost': instance.serverHost,
      'serverPort': instance.serverPort,
      'useTls': instance.useTls,
      'useOnlyTrustedCertificates': instance.useOnlyTrustedCertificates,
    };

IRCNetworkUserPreferences _$IRCNetworkUserPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkUserPreferences(
    nickname: json['nickname'] as String,
    password: json['password'] as String,
    realName: json['realName'] as String,
    username: json['username'] as String,
    channels: (json['channels'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$IRCNetworkUserPreferencesToJson(
        IRCNetworkUserPreferences instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'username': instance.username,
      'password': instance.password,
      'realName': instance.realName,
      'channels': instance.channels,
    };

IRCNetworkPreferences _$IRCNetworkPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkPreferences(
    serverPreferences: json['serverPreferences'] == null
        ? null
        : IRCNetworkServerPreferences.fromJson(
            json['serverPreferences'] as Map<String, dynamic>),
    userPreferences: json['userPreferences'] == null
        ? null
        : IRCNetworkUserPreferences.fromJson(
            json['userPreferences'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$IRCNetworkPreferencesToJson(
        IRCNetworkPreferences instance) =>
    <String, dynamic>{
      'serverPreferences': instance.serverPreferences,
      'userPreferences': instance.userPreferences,
    };
