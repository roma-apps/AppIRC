import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_model.g.dart';

class Network {
  int get localId => connectionPreferences.localId;

  set localId(int newId) => connectionPreferences.localId = newId;
  ChatNetworkConnectionPreferences connectionPreferences;

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
    return 'Network{name: $name, remoteId: $remoteId, channels: $channels}';
  }
}

@JsonSerializable()
class ChatNetworkServerPreferences extends JsonPreferences {
  String name;
  String serverHost;
  String serverPort;
  bool useTls;
  bool useOnlyTrustedCertificates;

  ChatNetworkServerPreferences({
    @required this.name,
    @required this.serverHost,
    @required this.serverPort,
    @required this.useTls,
    @required this.useOnlyTrustedCertificates,
  });


  @override
  String toString() {
    return 'ChatNetworkServerPreferences{name: $name, serverHost: '
        '$serverHost, serverPort: $serverPort, useTls: $useTls, '
        'useOnlyTrustedCertificates: $useOnlyTrustedCertificates}';
  }

  factory ChatNetworkServerPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatNetworkServerPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatNetworkServerPreferencesToJson(this);
}

@JsonSerializable()
class ChatNetworkUserPreferences extends JsonPreferences {
  String nickname;
  String username;
  String password;
  String realName;
  String commands;

  ChatNetworkUserPreferences(
      {@required this.nickname,
      @required this.password,
      @required this.commands,
      @required this.realName,
      @required this.username});

  @override
  String toString() {
    return 'ChatNetworkUserPreferences{nickname: $nickname,'
        ' username: $username,'
        ' commands: $commands,'
        ' password: $password, realName: $realName}';
  }

  factory ChatNetworkUserPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatNetworkUserPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatNetworkUserPreferencesToJson(this);
}

@JsonSerializable()
class ChatNetworkChannelPreferences extends JsonPreferences {
  int localId;
  final String name;
  final String password;

  ChatNetworkChannelPreferences(this.localId, this.password, this.name);

  ChatNetworkChannelPreferences.name(
      {@required this.name, @required this.password, this.localId});

  @override
  String toString() {
    return 'ChatNetworkChannelPreferences{localId: $localId, '
        'name: $name, password: $password}';
  }

  factory ChatNetworkChannelPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatNetworkChannelPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatNetworkChannelPreferencesToJson(this);
}

typedef ChatNetworkPreferencesActionCallback = void Function(
    BuildContext context, ChatNetworkPreferences preferences);

@JsonSerializable()
class ChatNetworkPreferences extends JsonPreferences {
  int get localId => networkConnectionPreferences?.localId;

  int get localIdOrUndefined => localId != null ? localId : -1;
  static const String channelsSeparator = " ";

  ChatNetworkConnectionPreferences networkConnectionPreferences;

  List<ChatNetworkChannelPreferences> channels;

  ChatNetworkPreferences(this.networkConnectionPreferences, this.channels);

  @override
  String toString() {
    return 'ChatNetworkPreferences{'
        'networkConnectionPreferences: $networkConnectionPreferences, '
        'channels: $channels}';
  }

  @JsonKey(ignore: true)
  List<ChatNetworkChannelPreferences> get channelsWithoutPassword => channels
      .where(
          (channel) => (channel.password == null || channel.password.isEmpty))
      .toList();

  @JsonKey(ignore: true)
  List<ChatNetworkChannelPreferences> get channelsWithPassword => channels
      .where((channel) =>
          (channel.password != null && channel.password.isNotEmpty))
      .toList();

  factory ChatNetworkPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatNetworkPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatNetworkPreferencesToJson(this);
}

@JsonSerializable()
class ChatNetworkConnectionPreferences extends JsonPreferences {
  int localId;

  ChatNetworkServerPreferences serverPreferences;
  ChatNetworkUserPreferences userPreferences;

  ChatNetworkConnectionPreferences(
      {@required this.serverPreferences,
      @required this.userPreferences,
      this.localId});

  get name => serverPreferences.name;

  @override
  String toString() {
    return 'ChatNetworkConnectionPreferences{localId: $localId,'
        ' serverPreferences: $serverPreferences,'
        ' userPreferences: $userPreferences}';
  }

  factory ChatNetworkConnectionPreferences.fromJson(
          Map<String, dynamic> json) =>
      _$ChatNetworkConnectionPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ChatNetworkConnectionPreferencesToJson(this);
}

class NetworkState {
  static final NetworkState empty = NetworkState.name(
      connected: false, secure: false, nick: null, name: null);

  bool connected;
  bool secure;
  String nick;
  String name;

  NetworkState(this.connected, this.secure, this.nick, this.name);

  NetworkState.name(
      {@required this.connected,
      @required this.secure,
      @required this.nick,
      @required this.name});
}

class NetworkWithState {
  final Network network;
  final NetworkState state;

  final List<NetworkChannelWithState> channelsWithState;

  NetworkWithState(this.network, this.state, this.channelsWithState);
}
