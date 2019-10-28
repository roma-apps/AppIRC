import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_user_preferences_model.g.dart';

@JsonSerializable()
class NetworkUserPreferences extends JsonPreferences {
  String nickname;
  String username;
  String password;
  String realName;
  String commands;

  NetworkUserPreferences(
      {@required this.nickname,
      @required this.password,
      @required this.commands,
      @required this.realName,
      @required this.username});

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
}
