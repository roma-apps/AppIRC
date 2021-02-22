import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';

class NetworkTitle {
  final String name;
  final String nick;

  NetworkTitle(this.name, this.nick);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkTitle &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          nick == other.nick;

  @override
  int get hashCode => name.hashCode ^ nick.hashCode;

  @override
  String toString() {
    return 'NetworkTitle{'
        'name: $name, '
        'nick: $nick'
        '}';
  }
}

class Network {
  int get localId => connectionPreferences.localId;

  set localId(int newId) => connectionPreferences.localId = newId;
  NetworkConnectionPreferences connectionPreferences;

  String get name => connectionPreferences.name;
  final String remoteId;

  final List<Channel> channels;

  Network(
    this.connectionPreferences,
    this.remoteId,
    this.channels,
  );

  Network.name(
      {@required this.connectionPreferences,
      @required this.remoteId,
      @required this.channels});

  List<Channel> get channelsWithoutLobby => channels
      .where(
        (channel) => !channel.isLobby,
      )
      .toList();

  Channel get lobbyChannel => channels.firstWhere(
        (channel) => channel.isLobby,
      );

  @override
  String toString() {
    return 'Network{'
        'name: $name, '
        'remoteId: $remoteId, '
        'channels: $channels'
        '}';
  }
}
