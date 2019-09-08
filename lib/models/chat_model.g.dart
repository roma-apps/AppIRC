// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IRCNetworksPreferences _$IRCNetworksPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworksPreferences(
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : IRCNetworkPreferences.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$IRCNetworksPreferencesToJson(
        IRCNetworksPreferences instance) =>
    <String, dynamic>{
      'networks': instance.networks,
    };

IRCNetworkPreferences _$IRCNetworkPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkPreferences(
    networkPreferences: json['networkPreferences'] == null
        ? null
        : IRCNetworkServerPreferences.fromJson(
            json['networkPreferences'] as Map<String, dynamic>),
    userPreferences: json['userPreferences'] == null
        ? null
        : IRCNetworkUserPreferences.fromJson(
            json['userPreferences'] as Map<String, dynamic>),
    channels: (json['channels'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$IRCNetworkPreferencesToJson(
        IRCNetworkPreferences instance) =>
    <String, dynamic>{
      'networkPreferences': instance.networkPreferences,
      'userPreferences': instance.userPreferences,
      'channels': instance.channels,
    };

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
  );
}

Map<String, dynamic> _$IRCNetworkUserPreferencesToJson(
        IRCNetworkUserPreferences instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'username': instance.username,
      'password': instance.password,
      'realName': instance.realName,
    };
