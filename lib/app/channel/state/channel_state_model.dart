import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';

class ChannelWithState {
  final Channel channel;
  final ChannelState state;
  final List<ChatMessage> initMessages;
  final List<ChannelUser> initUsers;

  ChannelWithState(this.channel, this.state, this.initMessages, this.initUsers);

  @override
  String toString() => 'ChannelWithState{'
        'channel: $channel, '
        'state: $state,'
        'initMessages: $initMessages, '
        'initUsers: $initUsers'
        '}';
}

class ChannelState {
  String topic;
  bool editTopicPossible;
  int unreadCount;
  bool connected;
  bool highlighted;
  bool moreHistoryAvailable;
  int firstUnreadRemoteMessageId;

  ChannelState(
      this.topic,
      this.editTopicPossible,
      this.unreadCount,
      this.connected,
      this.highlighted,
      this.moreHistoryAvailable,
      this.firstUnreadRemoteMessageId);

  ChannelState.name(
      {@required this.topic,
      @required this.editTopicPossible,
      @required this.unreadCount,
      @required this.connected,
      @required this.highlighted,
      @required this.moreHistoryAvailable,
      @required this.firstUnreadRemoteMessageId});

  static final ChannelState empty = ChannelState.name(
      topic: null,
      editTopicPossible: false,
      unreadCount: 0,
      connected: false,
      highlighted: false,
      moreHistoryAvailable: false,
      firstUnreadRemoteMessageId: null);

  @override
  String toString() {
    return 'ChannelState{topic: $topic, '
        'editTopicPossible: $editTopicPossible, unreadCount: $unreadCount, '
        'connected: $connected, highlighted: $highlighted, '
        'moreHistoryAvailable: $moreHistoryAvailable, '
        'firstUnread: $firstUnreadRemoteMessageId}';
  }
}
