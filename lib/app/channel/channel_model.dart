import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class NetworkChannel {
  int get localId => channelPreferences?.localId;

  set localId(int newId) => channelPreferences.localId = newId;

  final IRCNetworkChannelPreferences channelPreferences;

  String get name => channelPreferences.name;
  final IRCNetworkChannelType type;

  final int remoteId;

  bool get isLobby => type == IRCNetworkChannelType.LOBBY;

  NetworkChannel(this.channelPreferences, this.type, this.remoteId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkChannel &&
          runtimeType == other.runtimeType &&
          remoteId == other.remoteId;

  @override
  int get hashCode => remoteId.hashCode;
}

enum IRCNetworkChannelType { LOBBY, SPECIAL, QUERY, CHANNEL, UNKNOWN }

class NetworkChannelWithState {
  final NetworkChannel channel;
  final NetworkChannelState state;

  NetworkChannelWithState(this.channel, this.state);
}

class NetworkChannelState {
  String topic;
  bool editTopicPossible;
  int unreadCount;
  bool connected;
  bool highlighted;

  NetworkChannelState(this.topic, this.editTopicPossible, this.unreadCount,
      this.connected, this.highlighted);

  NetworkChannelState.name(
      {@required this.topic,
      @required this.editTopicPossible,
      @required this.unreadCount,
      @required this.connected,
      @required this.highlighted});

  static final NetworkChannelState empty = NetworkChannelState.name(
      topic: null,
      editTopicPossible: false,
      unreadCount: 0,
      connected: false,
      highlighted: false);
}

class NetworkChannelInfo {
  final String name;
  final String topic;
  final int usersCount;

  NetworkChannelInfo(this.name, this.topic, this.usersCount);
}
