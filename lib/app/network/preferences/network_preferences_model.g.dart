// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkPreferences _$NetworkPreferencesFromJson(Map<String, dynamic> json) {
  return NetworkPreferences(
    json['networkConnectionPreferences'] == null
        ? null
        : NetworkConnectionPreferences.fromJson(
            json['networkConnectionPreferences'] as Map<String, dynamic>),
    (json['channels'] as List)
        ?.map((e) => e == null
            ? null
            : ChannelPreferences.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$NetworkPreferencesToJson(NetworkPreferences instance) =>
    <String, dynamic>{
      'networkConnectionPreferences': instance.networkConnectionPreferences,
      'channels': instance.channels,
    };

NetworkConnectionPreferences _$NetworkConnectionPreferencesFromJson(
    Map<String, dynamic> json) {
  return NetworkConnectionPreferences(
    serverPreferences: json['serverPreferences'] == null
        ? null
        : NetworkServerPreferences.fromJson(
            json['serverPreferences'] as Map<String, dynamic>),
    userPreferences: json['userPreferences'] == null
        ? null
        : NetworkUserPreferences.fromJson(
            json['userPreferences'] as Map<String, dynamic>),
    localId: json['localId'] as int,
  );
}

Map<String, dynamic> _$NetworkConnectionPreferencesToJson(
        NetworkConnectionPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'serverPreferences': instance.serverPreferences,
      'userPreferences': instance.userPreferences,
    };
