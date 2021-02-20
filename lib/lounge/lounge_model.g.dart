// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lounge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoungeHostPreferences _$LoungeHostPreferencesFromJson(
    Map<String, dynamic> json) {
  return LoungeHostPreferences(
    host: json['host'] as String,
  );
}

Map<String, dynamic> _$LoungeHostPreferencesToJson(
        LoungeHostPreferences instance) =>
    <String, dynamic>{
      'host': instance.host,
    };

LoungeAuthPreferences _$LoungeAuthPreferencesFromJson(
    Map<String, dynamic> json) {
  return LoungeAuthPreferences(
    json['username'] as String,
    json['password'] as String,
  );
}

Map<String, dynamic> _$LoungeAuthPreferencesToJson(
        LoungeAuthPreferences instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoungePreferences _$LoungePreferencesFromJson(Map<String, dynamic> json) {
  return LoungePreferences(
    json['hostPreferences'] == null
        ? null
        : LoungeHostPreferences.fromJson(
            json['hostPreferences'] as Map<String, dynamic>),
    authPreferences: json['authPreferences'] == null
        ? null
        : LoungeAuthPreferences.fromJson(
            json['authPreferences'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LoungePreferencesToJson(LoungePreferences instance) =>
    <String, dynamic>{
      'hostPreferences': instance.hostPreferences,
      'authPreferences': instance.authPreferences,
    };
