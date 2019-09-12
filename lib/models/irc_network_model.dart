import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'irc_network_model.g.dart';



class IRCNetworkStatus {
  final bool connected;

  IRCNetworkStatus(this.connected);

  @override
  String toString() {
    return 'IRCNetworkStatus{connected: $connected}';
  }


}

class IRCNetwork {
  final String name;
  final String remoteId;

  final IRCNetworkStatus status;

  final List<IRCNetworkChannel> channels;

  List<IRCNetworkChannel> get channelsWithoutLobby =>
      channels.where((channel) => !channel.isLobby).toList();


  IRCNetworkChannel get lobbyChannel =>
      channels.firstWhere((channel) => channel.isLobby);

  IRCNetwork(this.name, this.remoteId, this.channels, this.status);

  static IRCNetworkChannel calculateChannelForCommand(IRCNetwork network) =>
      network != null && network.channels != null && network.channels.isNotEmpty
          ? network.channels[0]
          : null;

  @override
  String toString() {
    return 'IRCNetwork{name: $name, remoteId: $remoteId, status: $status, channels: $channels}';
  }

}

class IRCNetworkSettingsWrapper {
  final IRCNetwork ircNetwork;
  final bool collapsed;

  IRCNetworkSettingsWrapper(this.ircNetwork, this.collapsed);
}

@JsonSerializable()
class IRCNetworkServerPreferences extends Preferences {
  final String name;
  final String serverHost;
  final String serverPort;
  final bool useTls;
  final bool useOnlyTrustedCertificates;

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
class IRCNetworkUserPreferences extends Preferences {
  static const String channelsSeparator = " ";
  final String nickname;
  final String username;
  final String password;
  final String realName;
  List<String> channels;

  String get channelsString => channels.join(channelsSeparator);

  IRCNetworkUserPreferences({@required this.nickname,
    this.password,
    @required this.realName,
    @required this.username,
    @required this.channels});

  @override
  String toString() {
    return 'IRCNetworkUserPreferences{nickname: $nickname, username: $username,'
        ' password: $password, realName: $realName, channels: $channels}';
  }

  factory IRCNetworkUserPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkUserPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkUserPreferencesToJson(this);
}

@JsonSerializable()
class IRCNetworkPreferences extends Preferences {
  IRCNetworkServerPreferences serverPreferences;
  IRCNetworkUserPreferences userPreferences;

  IRCNetworkPreferences(
      {@required this.serverPreferences, @required this.userPreferences});

  @override
  String toString() {
    return 'IRCNetworkPreferences{networkPreferences: $serverPreferences,'
        ' userPreferences: $userPreferences}';
  }

  factory IRCNetworkPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworkPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IRCNetworkPreferencesToJson(this);
}
