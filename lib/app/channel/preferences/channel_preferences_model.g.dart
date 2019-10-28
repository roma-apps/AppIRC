// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelPreferences _$ChannelPreferencesFromJson(Map<String, dynamic> json) {
  return ChannelPreferences(
    json['localId'] as int,
    json['password'] as String,
    json['name'] as String,
  );
}

Map<String, dynamic> _$ChannelPreferencesToJson(ChannelPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'name': instance.name,
      'password': instance.password,
    };
