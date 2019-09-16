// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatPreferences _$ChatPreferencesFromJson(Map<String, dynamic> json) {
  return ChatPreferences(
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : IRCNetworkPreferences.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ChatPreferencesToJson(ChatPreferences instance) =>
    <String, dynamic>{
      'networks': instance.networks,
    };
