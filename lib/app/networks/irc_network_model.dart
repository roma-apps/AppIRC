import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'irc_network_model.g.dart';

enum IRCNetworkState { CONNECTED, DISCONNECTED }

class IRCNetworkStatus {

  final bool secure;

  IRCNetworkStatus({ @required this.secure});

  @override
  String toString() {
    return 'IRCNetworkStatus{ secure: $secure}';
  }
}

class IRCNetwork {
  int get localId => connectionPreferences?.localId;
  final IRCNetworkConnectionPreferences connectionPreferences;

  String get name => connectionPreferences.name;
  final String remoteId;

  final IRCNetworkStatus status;

  final List<IRCNetworkChannel> channels;

  IRCNetwork({@required this.connectionPreferences,
    @required this.remoteId,
    @required this.status,
    @required this.channels});

  List<IRCNetworkChannel> get channelsWithoutLobby =>
      channels.where((channel) => !channel.isLobby).toList();

  IRCNetworkChannel get lobbyChannel =>
      channels.firstWhere((channel) => channel.isLobby);

  @override
  String toString() {
    return 'IRCNetwork{name: $name, remoteId: $remoteId, status: $status, channels: $channels}';
  }
}

@JsonSerializable()
class IRCNetworkServerPreferences extends JsonPreferences {
  String name;
  String serverHost;
  String serverPort;
  bool useTls;
  bool useOnlyTrustedCertificates;

  IRCNetworkServerPreferences({@required this.name,
    @required this.serverHost,
    @required this.serverPort,
    @required this.useTls,
    @required this.useOnlyTrustedCertificates});

  @override
  String toString() {
    return 'IRCNetworkServerPreferences{name: $name}';
  }

  factory IRCNetworkServerPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkServerPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkServerPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkUserPreferences extends JsonPreferences {
  String nickname;
  String username;
  String password;
  String realName;

  IRCNetworkUserPreferences({@required this.nickname,
    this.password,
    @required this.realName,
    @required this.username});

  @override
  String toString() {
    return 'IRCNetworkUserPreferences{nickname: $nickname, username: $username,'
        ' password: $password, realName: $realName}';
  }

  factory IRCNetworkUserPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkUserPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkUserPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkChannelPreferences extends JsonPreferences {
  final int localId;
  final bool isLobby;
  final String name;
  final String password;

  IRCNetworkChannelPreferences(
      {this.localId, this.password, @required this.name, @required this.isLobby});

  @override
  String toString() {
    return 'IRCNetworkChannelPreferences{localId: $localId,'
        ' isLobby: $isLobby, name: $name}';
  }

  factory IRCNetworkChannelPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkChannelPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkChannelPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkPreferences extends JsonPreferences {
  int get localId => networkConnectionPreferences?.localId;

  int get localIdOrUndefined => localId != null ? localId : -1;
  static const String channelsSeparator = " ";

  final IRCNetworkConnectionPreferences networkConnectionPreferences;

  List<IRCNetworkChannelPreferences> channels;

  IRCNetworkPreferences(
      {@required this.networkConnectionPreferences, @required this.channels});

  @override
  String toString() {
    return 'IRCNetworkPreferences{'
        'networkConnectionPreferences: $networkConnectionPreferences, '
        'channels: $channels}';
  }

  String get channelsString =>
      channels.map((channel) => channel.name).join(channelsSeparator);

  @JsonKey(ignore: true)
  String get notLobbyChannelsString =>
      channels
          .where((channel) => !channel.isLobby)
          .map((channel) => channel.name)
          .join(channelsSeparator);

  @JsonKey(ignore: true)
  set notLobbyChannelsString(String newValue) =>
      channels = newValue != null
          ? newValue
          .split(channelsSeparator)
          .map((channelName) =>
          IRCNetworkChannelPreferences(name: channelName, isLobby: false))
          .toList()
          : [];

  factory IRCNetworkPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkConnectionPreferences extends JsonPreferences {
  final int localId;

  IRCNetworkServerPreferences serverPreferences;
  IRCNetworkUserPreferences userPreferences;

  IRCNetworkConnectionPreferences({@required this.serverPreferences,
    @required this.userPreferences,
    @required this.localId});

  get name => serverPreferences.name;

  @override
  String toString() {
    return 'IRCNetworkConnectionPreferences{localId: $localId,'
        ' serverPreferences: $serverPreferences,'
        ' userPreferences: $userPreferences}';
  }

  factory IRCNetworkConnectionPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkConnectionPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$IRCNetworkConnectionPreferencesToJson(this);
}
