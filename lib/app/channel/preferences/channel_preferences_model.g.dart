// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelPreferences _$ChannelPreferencesFromJson(Map<String, dynamic> json) {
  return ChannelPreferences(
    name: json['name'] as String,
    password: json['password'] as String,
    localId: json['localId'] as int,
  );
}

Map<String, dynamic> _$ChannelPreferencesToJson(ChannelPreferences instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'name': instance.name,
      'password': instance.password,
    };
