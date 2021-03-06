import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/json/json_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_user_preferences_model.g.dart';

@JsonSerializable()
class NetworkUserPreferences extends IJsonObject {
  String nickname;
  final String username;
  final String password;
  final String realName;
  final String commands;

  NetworkUserPreferences({
    @required this.nickname,
    @required this.password,
    @required this.commands,
    @required this.realName,
    @required this.username,
  });

  @override
  String toString() {
    return 'NetworkUserPreferences{nickname: $nickname,'
        ' username: $username,'
        ' commands: $commands,'
        ' password: $password, realName: $realName}';
  }

  factory NetworkUserPreferences.fromJson(Map<String, dynamic> json) =>
      _$NetworkUserPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NetworkUserPreferencesToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkUserPreferences &&
          runtimeType == other.runtimeType &&
          nickname == other.nickname &&
          username == other.username &&
          password == other.password &&
          realName == other.realName &&
          commands == other.commands;

  @override
  int get hashCode =>
      nickname.hashCode ^
      username.hashCode ^
      password.hashCode ^
      realName.hashCode ^
      commands.hashCode;
}
