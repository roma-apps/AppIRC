import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

class Channel {
  String name;

  final int remoteId;

  @override
  String toString() {
    return 'Channel{name: $name, remoteId: $remoteId}';
  }

  Channel({@required this.name, @required this.remoteId});
}

class Network {
  String name;
  final String remoteId;

  List<Channel> channels;

  Network(this.name, this.remoteId, this.channels);

  @override
  String toString() {
    return 'Network{name: $name, remoteId: $remoteId, channels: $channels}';
  }
}

class ChannelMessage {
  String type;
  String author;
  String realName;
  DateTime date;
  String text;

  ChannelMessage.name(
      {this.type, this.author, this.realName, this.date, this.text});

  @override
  String toString() {
    return 'ChannelMessage{author: $author, text: $text}';
  }
}

@JsonSerializable()
class IRCNetworksPreferences extends Preferences {
  final List<IRCNetworkPreferences> networks;

  IRCNetworksPreferences(this.networks);

  @override
  String toString() {
    return 'IRCNetworksConnectionPreferences{networks: $networks}';
  }

  @override
  Map<String, dynamic> toJson() => _$IRCNetworksPreferencesToJson(this);

  factory IRCNetworksPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworksPreferencesFromJson(json);
}

@JsonSerializable()
class IRCNetworkPreferences extends Preferences {
  IRCNetworkServerPreferences networkPreferences;
  IRCNetworkUserPreferences userPreferences;
  List<String> channels;

  IRCNetworkPreferences(
      {@required this.networkPreferences,
      @required this.userPreferences,
      @required this.channels});

  factory IRCNetworkPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkServerPreferences extends Preferences {
  String name;
  String serverHost;
  String serverPort;
  bool useTls;
  bool useOnlyTrustedCertificates;

  IRCNetworkServerPreferences(
      {@required this.name,
      @required this.serverHost,
      @required this.serverPort,
      @required this.useTls,
      @required this.useOnlyTrustedCertificates});

  @override
  String toString() {
    return 'NetworkPreferences{name: $name}';
  }

  factory IRCNetworkServerPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkServerPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkServerPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkUserPreferences extends Preferences {
  String nickname;
  String username;
  String password;
  String realName;

  IRCNetworkUserPreferences(
      {@required this.nickname,
      this.password,
      @required this.realName,
      @required this.username});

  @override
  String toString() {
    return 'UserPreferences{nickname: $nickname, username: $username, password: $password, realName: $realName}';
  }

  factory IRCNetworkUserPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkUserPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkUserPreferencesToJson(this);
}
