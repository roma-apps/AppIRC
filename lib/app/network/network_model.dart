import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_model.g.dart';

class Network {
  int get localId => connectionPreferences.localId;

  set localId(int newId) => connectionPreferences.localId = newId;
  final IRCNetworkConnectionPreferences connectionPreferences;

  String get name => connectionPreferences.name;
  final String remoteId;

  final List<NetworkChannel> channels;

  Network(this.connectionPreferences, this.remoteId, this.channels);

  Network.name(
      {@required this.connectionPreferences,
      @required this.remoteId,
      @required this.channels});

  List<NetworkChannel> get channelsWithoutLobby =>
      channels.where((channel) => !channel.isLobby).toList();

  NetworkChannel get lobbyChannel =>
      channels.firstWhere((channel) => channel.isLobby);

  @override
  String toString() {
    return 'IRCNetwork{name: $name, remoteId: $remoteId, channels: $channels}';
  }
}

@JsonSerializable()
class IRCNetworkServerPreferences extends JsonPreferences {
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

  IRCNetworkUserPreferences(
      {@required this.nickname,
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
  int localId;
  final String name;
  final String password;

  IRCNetworkChannelPreferences(this.localId, this.password, this.name);

  IRCNetworkChannelPreferences.name(
      {@required this.name, @required this.password, this.localId});

  @override
  String toString() {
    return 'IRCNetworkChannelPreferences{localId: $localId, name: $name}';
  }

  factory IRCNetworkChannelPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkChannelPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkChannelPreferencesToJson(this);
}

typedef PreferencesActionCallback = void Function(
    BuildContext context, IRCNetworkPreferences preferences);

@JsonSerializable()
class IRCNetworkPreferences extends JsonPreferences {
  int get localId => networkConnectionPreferences?.localId;

  int get localIdOrUndefined => localId != null ? localId : -1;
  static const String channelsSeparator = " ";

  final IRCNetworkConnectionPreferences networkConnectionPreferences;

  List<IRCNetworkChannelPreferences> channels;

  IRCNetworkPreferences(this.networkConnectionPreferences, this.channels);

  @override
  String toString() {
    return 'IRCNetworkPreferences{'
        'networkConnectionPreferences: $networkConnectionPreferences, '
        'channels: $channels}';
  }

  @JsonKey(ignore: true)
  List<IRCNetworkChannelPreferences> get channelsWithoutPassword => channels
      .where(
          (channel) => (channel.password == null || channel.password.isEmpty))
      .toList();

  @JsonKey(ignore: true)
  List<IRCNetworkChannelPreferences> get channelsWithPassword => channels
      .where((channel) =>
          (channel.password != null && channel.password.isNotEmpty))
      .toList();

  factory IRCNetworkPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkConnectionPreferences extends JsonPreferences {
  int localId;

  IRCNetworkServerPreferences serverPreferences;
  IRCNetworkUserPreferences userPreferences;

  IRCNetworkConnectionPreferences(
      {@required this.serverPreferences,
      @required this.userPreferences,
      this.localId});

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
