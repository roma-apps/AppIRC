import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class NetworkState {
  static const NetworkState empty = NetworkState(
    connected: false,
    secure: false,
    nick: null,
    name: null,
  );

  final bool connected;
  final bool secure;
  final String nick;
  final String name;

  const NetworkState({
    @required this.connected,
    @required this.secure,
    @required this.nick,
    @required this.name,
  });

  NetworkState copyWith({
    bool connected,
    bool secure,
    String nick,
    String name,
  }) => NetworkState(
      connected: connected ?? this.connected,
      secure: secure ?? this.secure,
      nick: nick ?? this.nick,
      name: name ?? this.name,
    );

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

  NetworkWithState({
    @required this.network,
    @required this.state,
    @required this.channelsWithState,
  });

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

  NetworkWithState copyWith({
    Network network,
    NetworkState state,
    List<ChannelWithState> channelsWithState,
  }) => NetworkWithState(
      network: network ?? this.network,
      state: state ?? this.state,
      channelsWithState: channelsWithState ?? this.channelsWithState,
    );
}
