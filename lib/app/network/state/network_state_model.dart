import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class NetworkState {
  static final NetworkState empty = NetworkState.name(
    connected: false,
    secure: false,
    nick: null,
    name: null,
  );

  bool connected;
  bool secure;
  String nick;
  String name;

  NetworkState(
    this.connected,
    this.secure,
    this.nick,
    this.name,
  );

  NetworkState.name({
    @required this.connected,
    @required this.secure,
    @required this.nick,
    @required this.name,
  });

  @override
  String toString() {
    return 'NetworkState{'
        'connected: $connected, '
        'secure: $secure, '
        'nick: $nick, '
        'name: $name'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkState &&
          runtimeType == other.runtimeType &&
          connected == other.connected &&
          secure == other.secure &&
          nick == other.nick &&
          name == other.name;

  @override
  int get hashCode =>
      connected.hashCode ^ secure.hashCode ^ nick.hashCode ^ name.hashCode;
}

class NetworkWithState {
  final Network network;
  final NetworkState state;

  final List<ChannelWithState> channelsWithState;

  NetworkWithState(this.network, this.state, this.channelsWithState);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkWithState &&
          runtimeType == other.runtimeType &&
          network == other.network &&
          state == other.state &&
          channelsWithState == other.channelsWithState;

  @override
  int get hashCode =>
      network.hashCode ^ state.hashCode ^ channelsWithState.hashCode;

  @override
  String toString() {
    return 'NetworkWithState{'
        'network: $network, '
        'state: $state, '
        'channelsWithState: $channelsWithState'
        '}';
  }
}
