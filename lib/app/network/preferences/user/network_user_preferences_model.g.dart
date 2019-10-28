// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_user_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkUserPreferences _$NetworkUserPreferencesFromJson(
    Map<String, dynamic> json) {
  return NetworkUserPreferences(
    nickname: json['nickname'] as String,
    password: json['password'] as String,
    commands: json['commands'] as String,
    realName: json['realName'] as String,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$NetworkUserPreferencesToJson(
        NetworkUserPreferences instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'username': instance.username,
      'password': instance.password,
      'realName': instance.realName,
      'commands': instance.commands,
    };
