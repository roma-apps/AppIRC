import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class NetworkChannel {
  int get localId => channelPreferences?.localId;

  set localId(int newId) => channelPreferences.localId = newId;

  final ChatNetworkChannelPreferences channelPreferences;

  String get name => channelPreferences.name;
  final NetworkChannelType type;

  final int remoteId;

  bool get isLobby => type == NetworkChannelType.LOBBY;

  NetworkChannel(this.channelPreferences, this.type, this.remoteId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkChannel &&
          runtimeType == other.runtimeType &&
          remoteId == other.remoteId;

  @override
  int get hashCode => remoteId.hashCode;

  @override
  String toString() {
    return 'NetworkChannel{channelPreferences: $channelPreferences,'
        ' type: $type, remoteId: $remoteId}';
  }


}

enum NetworkChannelType { LOBBY, SPECIAL, QUERY, CHANNEL, UNKNOWN }

class NetworkChannelWithState {
  final NetworkChannel channel;
  final NetworkChannelState state;

  NetworkChannelWithState(this.channel, this.state);

  @override
  String toString() {
    return 'NetworkChannelWithState{channel: $channel, state: $state}';
  }


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

  @override
  String toString() {
    return 'NetworkChannelState{topic: $topic, '
        'editTopicPossible: $editTopicPossible, '
        'unreadCount: $unreadCount,'
        ' connected: $connected, highlighted: $highlighted}';
  }


}

