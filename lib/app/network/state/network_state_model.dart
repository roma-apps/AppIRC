import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

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

  @override
  String toString() {
    return 'NetworkState{connected: $connected, secure: $secure,'
        ' nick: $nick, name: $name}';
  }
}

class NetworkWithState {
  final Network network;
  final NetworkState state;

  final List<ChannelWithState> channelsWithState;

  NetworkWithState(this.network, this.state, this.channelsWithState);
}
