import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

class LoungeConstants {
  static const String channelsNamesSeparator = " ";
}

class ClientSideLoungeIRCCommandConstants {
  static const String expand = "/expand";
  static const String collapse = "/collapse";

}

class BooleanLoungeConstants {
  static const String on = "on";
  static const String off = "off";
}

class ChannelStateLoungeConstants {
  static const int connected = 1;
  static const int disconnected = 0;
}

class ChannelTypeLoungeConstants {
  static const lobby = "lobby";
  static const special = "special";
  static const query = "query";
  static const channel = "channel";
}

class MessageTypeLoungeConstants {
  static const lobby = "lobby";
  static const unhandled = "unhandled";
  static const topicSetBy = "topic_set_by";
  static const topic = "topic";
  static const message = "message";
  static const join = "join";
  static const mode = "mode";
  static const motd = "motd";
  static const whois = "whois";
  static const notice = "notice";
  static const error = "error";
  static const away = "away";
  static const back = "back";
  static const raw = "raw";
  static const modeChannel = "mode_channel";
  static const quit = "quit";
  static const part = "part";
  static const nick = "nick";
  static const ctcpRequest = "ctcp_request";
}

@JsonSerializable()
class LoungeHostPreferences extends JsonPreferences {
  String host;

  LoungeHostPreferences(this.host);

  LoungeHostPreferences.name({@required this.host});

  static LoungeHostPreferences empty =
      LoungeHostPreferences.name(host: null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeHostPreferences &&
          runtimeType == other.runtimeType &&
          host == other.host;

  @override
  int get hashCode => host.hashCode;

  @override
  String toString() {
    return 'LoungeHostPreferences{host: $host}';
  }

  @override
  Map<String, dynamic> toJson() => _$LoungeHostPreferencesToJson(this);

  factory LoungeHostPreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungeHostPreferencesFromJson(json);
}

@JsonSerializable()
class LoungeAuthPreferences extends JsonPreferences {
  final String username;
  final String password;

  LoungeAuthPreferences(this.username, this.password);

  LoungeAuthPreferences.name(
      {@required this.username, @required this.password});

  static LoungeAuthPreferences empty =
      LoungeAuthPreferences.name(username: null, password: null);

  @override
  String toString() {
    return 'LoungeAuthPreferences{username: $username, password: $password}';
  }

  @override
  Map<String, dynamic> toJson() => _$LoungeAuthPreferencesToJson(this);

  factory LoungeAuthPreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungeAuthPreferencesFromJson(json);
}

@JsonSerializable()
class LoungePreferences extends JsonPreferences {
  LoungeHostPreferences hostPreferences;
  LoungeAuthPreferences authPreferences;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungePreferences &&
          runtimeType == other.runtimeType &&
          hostPreferences == other.hostPreferences &&
          authPreferences == other.authPreferences;

  @override
  int get hashCode => hostPreferences.hashCode ^ authPreferences.hashCode;

  LoungePreferences(this.hostPreferences, {this.authPreferences});

  LoungePreferences.name(
      {@required this.hostPreferences, @required this.authPreferences});

  static LoungePreferences empty = LoungePreferences.name(
      hostPreferences: null, authPreferences: null);

  @override
  Map<String, dynamic> toJson() => _$LoungePreferencesToJson(this);

  factory LoungePreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungePreferencesFromJson(json);

  @override
  String toString() {
    return 'LoungePreferences{connectionPreferences: $hostPreferences,'
        ' authPreferences: $authPreferences}';
  }
}
