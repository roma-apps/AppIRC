import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'channel_preferences_model.g.dart';

@JsonSerializable()
class ChannelPreferences extends JsonPreferences {
  int localId;
  final String name;
  final String password;

  ChannelPreferences(this.localId, this.password, this.name);

  ChannelPreferences.name(
      {@required this.name, @required this.password, this.localId});

  @override
  String toString() {
    return 'ChatChannelPreferences{localId: $localId, '
        'name: $name, password: $password}';
  }

  factory ChannelPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChannelPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChannelPreferencesToJson(this);
}
