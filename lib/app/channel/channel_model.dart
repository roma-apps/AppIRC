import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class NetworkChannel {
  int get localId => channelPreferences?.localId;

  set localId(int newId) => channelPreferences.localId = newId;

  ChatNetworkChannelPreferences channelPreferences;

  String get name => channelPreferences.name;
  final NetworkChannelType type;

  final int remoteId;

  bool get isLobby => type == NetworkChannelType.lobby;

  bool get isCanHaveSeveralUsers => type == NetworkChannelType.channel;

  bool get isCanHaveTopic => type == NetworkChannelType.channel;

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

enum NetworkChannelType { lobby, special, query, channel, unknown }

class NetworkChannelWithState {
  final NetworkChannel channel;
  final NetworkChannelState state;
  final List<ChatMessage> initMessages;
  final List<NetworkChannelUser> initUsers;

  NetworkChannelWithState(
      this.channel, this.state, this.initMessages, this.initUsers);

  @override
  String toString() {
    return 'NetworkChannelWithState{channel: $channel, state: $state,'
        ' initMessages: $initMessages, initUsers: $initUsers}';
  }
}

class NetworkChannelState {
  String topic;
  bool editTopicPossible;
  int unreadCount;
  bool connected;
  bool highlighted;
  bool moreHistoryAvailable;
  int firstUnreadRemoteMessageId;

  NetworkChannelState(
      this.topic,
      this.editTopicPossible,
      this.unreadCount,
      this.connected,
      this.highlighted,
      this.moreHistoryAvailable,
      this.firstUnreadRemoteMessageId);

  NetworkChannelState.name(
      {@required this.topic,
      @required this.editTopicPossible,
      @required this.unreadCount,
      @required this.connected,
      @required this.highlighted,
      @required this.moreHistoryAvailable,
      @required this.firstUnreadRemoteMessageId});

  static final NetworkChannelState empty = NetworkChannelState.name(
      topic: null,
      editTopicPossible: false,
      unreadCount: 0,
      connected: false,
      highlighted: false,
      moreHistoryAvailable: false,
      firstUnreadRemoteMessageId: null);

  @override
  String toString() {
    return 'NetworkChannelState{topic: $topic, '
        'editTopicPossible: $editTopicPossible, unreadCount: $unreadCount, '
        'connected: $connected, highlighted: $highlighted, '
        'moreHistoryAvailable: $moreHistoryAvailable, '
        'firstUnread: $firstUnreadRemoteMessageId}';
  }
}

class VisibleMessagesBounds {
  ChatMessage min;
  ChatMessage max;

  VisibleMessagesBounds({@required this.min, @required this.max});

  @override
  String toString() {
    return 'VisibleMessagesBounds{min: $min, max: $max}';
  }
}
