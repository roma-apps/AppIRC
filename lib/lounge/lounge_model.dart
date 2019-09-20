import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

class LoungeConstants {
  static const String on = "on";
  static const String off = "off";
  static const String channelsNamesSeparator = " ";

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
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LoungeConnectionPreferences &&
              runtimeType == other.runtimeType &&
              host == other.host;

  @override
  int get hashCode => host.hashCode;

  @override
  String toString() {
    return 'LoungeConnectionPreferences{host: $host}';
  }

  @override
  Map<String, dynamic> toJson() => _$LoungeConnectionPreferencesToJson(this);

  factory LoungeConnectionPreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungeConnectionPreferencesFromJson(json);
}
