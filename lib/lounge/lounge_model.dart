import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

class LoungeConstants {
  static const String on = "on";
  static const String off = "off";
}

class LoungeChannelTypeConstants {
  static const lobby = "lobby";
  static const special = "special";
  static const query = "query";
  static const channel = "channel";
}

@JsonSerializable()
class LoungeConnectionPreferences extends JsonPreferences {
  final String host;

  LoungeConnectionPreferences({@required this.host});

  static LoungeConnectionPreferences empty =
      LoungeConnectionPreferences(host: null);

  @override
  String toString() {
    return 'LoungeConnectionPreferences{host: $host}';
  }

  @override
  Map<String, dynamic> toJson() => _$LoungeConnectionPreferencesToJson(this);

  factory LoungeConnectionPreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungeConnectionPreferencesFromJson(json);
}
