import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lounge_model.g.dart';

class LoungeConstants {
  static const String on = "on";
  static const String off = "off";
  static const String channelsNamesSeparator = " ";

  static const int CHANNEL_STATE_CONNECTED = 1;
  static const int CHANNEL_STATE_DISCONNECTED = 0;
}

class LoungeChannelTypeConstants {
  static const lobby = "lobby";
  static const special = "special";
  static const query = "query";
  static const channel = "channel";
}

class LoungeMessageTypeConstants {

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
class LoungeConnectionPreferences extends JsonPreferences {
   String host;

  LoungeConnectionPreferences(this.host);
  LoungeConnectionPreferences.name({@required this.host});

  static LoungeConnectionPreferences empty =
      LoungeConnectionPreferences.name(host: null);

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

@JsonSerializable()
class LoungeAuthPreferences extends JsonPreferences {
  final String username;
  final String password;

  LoungeAuthPreferences(this.username,this.password);
  LoungeAuthPreferences.name({@required this.username, @required this.password});

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
  LoungeConnectionPreferences connectionPreferences;
  LoungeAuthPreferences authPreferences;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LoungePreferences &&
              runtimeType == other.runtimeType &&
              connectionPreferences == other.connectionPreferences &&
              authPreferences == other.authPreferences;

  @override
  int get hashCode =>
      connectionPreferences.hashCode ^
      authPreferences.hashCode;

  LoungePreferences(this.connectionPreferences, {this.authPreferences});

  LoungePreferences.name(
      {@required this.connectionPreferences, @required this.authPreferences});

  static LoungePreferences empty =
      LoungePreferences.name(connectionPreferences: null, authPreferences: null);

  @override
  Map<String, dynamic> toJson() => _$LoungePreferencesToJson(this);

  factory LoungePreferences.fromJson(Map<String, dynamic> json) =>
      _$LoungePreferencesFromJson(json);

  @override
  String toString() {
    return 'LoungePreferences{connectionPreferences: $connectionPreferences,'
        ' authPreferences: $authPreferences}';
  }


}

typedef LoungePreferencesActionCallback = void Function(
    BuildContext context, LoungePreferences preferences);
