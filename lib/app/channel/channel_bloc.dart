import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/messages/channel_message_list_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/push/chat_push_service.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

final Duration _usersListOutDateDuration = Duration(seconds: 15);

class ChannelBloc extends DisposableOwner {
  final ChatBackendService backendService;
  final ChatPushesService chatPushesService;

  final Network network;
  Channel _channel;

  Channel get channel => _channel;
  final ChannelStatesBloc channelsStatesBloc;

  ChatInputMessageBloc _inputMessageBloc;

  ChannelMessageListBloc _messagesBloc;

  ChannelMessageListBloc get messagesBloc => _messagesBloc;

  ChatInputMessageBloc get inputMessageBloc => _inputMessageBloc;

  ChannelBloc({
    @required this.backendService,
    @required this.chatPushesService,
    @required this.network,
    @required ChannelWithState channelWithState,
    @required this.channelsStatesBloc,
  }) {
    _channel = channelWithState.channel;
    _usersSubject = BehaviorSubject.seeded(channelWithState.initUsers ?? []);

    _messagesBloc = ChannelMessageListBloc(
      chatPushesService: chatPushesService,
      channel: channel,
    );
    addDisposable(
      disposable: _messagesBloc,
    );

    addDisposable(subject: _usersSubject);
    addDisposable(
      disposable: backendService.listenForChannelNames(
        network: network,
        channel: channel,
        listener: (newUsers) {
          _usersSubject.add(newUsers);
        },
      ),
    );
    addDisposable(
      disposable: backendService.listenForChannelUsers(
        network: network,
        channel: channel,
        listener: () {
          backendService.requestChannelUsers(
            network: network,
            channel: channel,
          );
        },
      ),
    );
    _inputMessageBloc = ChatInputMessageBloc(
      backendService.chatConfig,
      this,
    );
    addDisposable(disposable: _inputMessageBloc);
  }

  // ignore: close_sinks
  BehaviorSubject<List<ChannelUser>> _usersSubject;

  Stream<List<ChannelUser>> get usersStream => _usersSubject.stream;

  List<ChannelUser> get users => _usersSubject.value;
  DateTime _lastUsersRefreshDate;

  Future<List<ChannelUser>> retrieveUsers({
    forceRefresh = false,
  }) async {
    if (forceRefresh || _lastUsersRefreshDate == null) {
      await requestUsersListUpdate();
    } else {
      var now = DateTime.now();

      var differenceDuration = now.difference(_lastUsersRefreshDate);
      if (differenceDuration > _usersListOutDateDuration) {
        await requestUsersListUpdate();
      }
    }

    return _usersSubject.value;
  }

  Future requestUsersListUpdate() async {
    _lastUsersRefreshDate = DateTime.now();
    await backendService.requestChannelUsers(
      network: network,
      channel: channel,
      waitForResult: false,
    );
  }

  ChannelState get channelState => channelsStatesBloc.getChannelState(
        network,
        channel,
      );

  Stream<ChannelState> get _channelStateStream =>
      channelsStatesBloc.getChannelStateStream(
        network,
        channel,
      );

  bool get channelConnected => channelState.connected;

  Stream<bool> get channelConnectedStream =>
      _channelStateStream.map((state) => state?.connected).distinct();

  // Lounge bug?
  // Sometimes lounge moreHistory is null but actually history exist
  bool get moreHistoryAvailable => channelState?.moreHistoryAvailable ?? true;

  // Lounge bug?
  // Sometimes lounge moreHistory is null but actually history exist
  Stream<bool> get moreHistoryAvailableStream =>
      _channelStateStream.map((state) => state?.moreHistoryAvailable);

  int get channelUnreadCount => channelState.unreadCount;

  Stream<int> get channelUnreadCountStream =>
      _channelStateStream.map((state) => state?.unreadCount).distinct();

  String get channelTopic => channelState.topic;

  Stream<String> get channelTopicStream =>
      _channelStateStream.map((state) => state?.topic).distinct();

  Future<RequestResult<bool>> leaveChannel({
    bool waitForResult = false,
  }) async =>
      await backendService.leaveChannel(
        network: network,
        channel: channel,
        waitForResult: waitForResult,
      );

  Future<RequestResult<ChannelUser>> printUserInfo(
    String userNick, {
    bool waitForResult = false,
  }) async =>
      await backendService.requestUserInfo(
        network: network,
        channel: channel,
        userNick: userNick,
        waitForResult: waitForResult,
      );

  Future<RequestResult<ChatMessage>> printChannelBannedUsers({
    bool waitForResult = false,
  }) async =>
      await backendService.printChannelBannedUsers(
        network: network,
        channel: channel,
        waitForResult: waitForResult,
      );

  Future<RequestResult<bool>> editChannelTopic(
    String newTopic, {
    bool waitForResult = false,
  }) async =>
      await backendService.editChannelTopic(
        network: network,
        channel: channel,
        newTopic: newTopic,
        waitForResult: waitForResult,
      );

  Future<RequestResult<bool>> onOpenChannel() async =>
      await backendService.sendChannelOpenedEventToServer(
        network: network,
        channel: channel,
      );

  Future<RequestResult<ChatMessage>> sendChannelRawMessage(
    String rawMessage, {
    bool waitForResult = false,
  }) async =>
      await backendService.sendChannelRawMessage(
        network: network,
        channel: channel,
        rawMessage: rawMessage,
        waitForResult: waitForResult,
      );

  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel(
          String nick) async =>
      await backendService.openDirectMessagesChannel(
        network: network,
        channel: channel,
        nick: nick,
      );

  static ChannelBloc of(
    BuildContext context, {
    bool listen = true,
  }) =>
      Provider.of<ChannelBloc>(
        context,
        listen: listen,
      );

  Future<RequestResult<MessageListLoadMore>> loadMoreHistory(
    RegularMessage oldestMessage,
  ) async =>
      await backendService.loadMoreHistory(
        network: network,
        channel: channel,
        lastMessageId: oldestMessage?.messageRemoteId,
      );

  Future<RequestResult<ToggleMessagePreviewData>> togglePreview(
    RegularMessage message,
    MessagePreview preview,
  ) =>
      backendService.togglePreview(
        network: network,
        channel: channel,
        message: message,
        preview: preview,
      );
}
