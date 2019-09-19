// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

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

IRCNetworkChannelPreferences _$IRCNetworkChannelPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkChannelPreferences(
    json['localId'] as int,
    json['password'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$IRCNetworkChannelPreferencesToJson(
        IRCNetworkChannelPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'name': instance.name,
      'password': instance.password,
    };

IRCNetworkPreferences _$IRCNetworkPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkPreferences(
    json['networkConnectionPreferences'] == null
        ? null
        : IRCNetworkConnectionPreferences.fromJson(
            json['networkConnectionPreferences'] as Map<String, dynamic>),
    (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : IRCNetworkChannelPreferences.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  )..channelsString = json['channelsString'] as String;
}

Map<String, dynamic> _$IRCNetworkPreferencesToJson(
        IRCNetworkPreferences instance) =>
    <String, dynamic>{
      'networkConnectionPreferences': instance.networkConnectionPreferences,
      'channels': instance.channels,
      'channelsString': instance.channelsString,
    };

IRCNetworkConnectionPreferences _$IRCNetworkConnectionPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworkConnectionPreferences(
    serverPreferences: json['serverPreferences'] == null
        ? null
        : IRCNetworkServerPreferences.fromJson(
            json['serverPreferences'] as Map<String, dynamic>),
    userPreferences: json['userPreferences'] == null
        ? null
        : IRCNetworkUserPreferences.fromJson(
            json['userPreferences'] as Map<String, dynamic>),
    localId: json['localId'] as int,
  );
}

Map<String, dynamic> _$IRCNetworkConnectionPreferencesToJson(
        IRCNetworkConnectionPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'serverPreferences': instance.serverPreferences,
      'userPreferences': instance.userPreferences,
    };
