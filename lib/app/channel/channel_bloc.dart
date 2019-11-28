import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/messages/channel_message_list_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

final Duration _usersListOutDateDuration = Duration(seconds: 15);

class ChannelBloc extends DisposableOwner implements MoreHistoryOwner {
  final ChatBackendService _backendService;
  final ChatPushesService chatPushesService;

  final Network network;
  Channel _channel;
  Channel get channel => _channel;
  final ChannelStatesBloc _channelsStatesBloc;

  ChatInputMessageBloc _inputMessageBloc;

  ChannelMessageListBloc _messagesBloc;

  ChannelMessageListBloc get messagesBloc => _messagesBloc;

  ChatInputMessageBloc get inputMessageBloc => _inputMessageBloc;

  ChannelBloc(this._backendService, this.chatPushesService, this.network,
      ChannelWithState channelWithState, this._channelsStatesBloc) {
    _channel = channelWithState.channel;
    _usersSubject =
        BehaviorSubject(seedValue: channelWithState.initUsers ?? []);

    _messagesBloc = ChannelMessageListBloc(chatPushesService, channel);
    addDisposable(disposable: _messagesBloc);

    addDisposable(subject: _usersSubject);
    addDisposable(
        disposable: _backendService
            .listenForChannelNames(network, channel, (newUsers) {
      _usersSubject.add(newUsers);
    }));
    addDisposable(
        disposable:
            _backendService.listenForChannelUsers(network, channel, () {
      _backendService.requestChannelUsers(network, channel);
    }));
    _inputMessageBloc = ChatInputMessageBloc(_backendService.chatConfig, this);
    addDisposable(disposable: _inputMessageBloc);
  }

  // ignore: close_sinks
  BehaviorSubject<List<ChannelUser>> _usersSubject;

  Stream<List<ChannelUser>> get usersStream => _usersSubject.stream;

  List<ChannelUser> get users => _usersSubject.value;
  DateTime _lastUsersRefreshDate;

  Future<List<ChannelUser>> retrieveUsers({forceRefresh: false}) async {
    if (forceRefresh || _lastUsersRefreshDate == null) {
      await requestUsersListUpdate();
    } else {
      var now = DateTime.now();

      var differenceDuration = now.difference(_lastUsersRefreshDate);
      if (differenceDuration > _usersListOutDateDuration) {
        requestUsersListUpdate();
      }
    }

    return _usersSubject.value;
  }

  requestUsersListUpdate() async {
    _lastUsersRefreshDate = DateTime.now();
    await _backendService.requestChannelUsers(network, channel,
        waitForResult: false);
  }

  ChannelState get channelState =>
      _channelsStatesBloc.getChannelState(network, channel);

  Stream<ChannelState> get _channelStateStream =>
      _channelsStatesBloc.getChannelStateStream(network, channel);

  bool get channelConnected => channelState.connected;

  Stream<bool> get channelConnectedStream =>
      _channelStateStream.map((state) => state?.connected).distinct();

  // Lounge bug?
  // Sometimes lounge moreHistory is null but actually history exist
  bool get moreHistoryAvailable =>
      channelState?.moreHistoryAvailable ?? true;

  // Lounge bug?
  // Sometimes lounge moreHistory is null but actually history exist
  Stream<bool> get moreHistoryAvailableStream =>
      _channelStateStream
          .map((state) => state?.moreHistoryAvailable);

  int get channelUnreadCount => channelState.unreadCount;

  Stream<int> get channelUnreadCountStream =>
      _channelStateStream.map((state) => state?.unreadCount).distinct();

  String get channelTopic => channelState.topic;

  Stream<String> get channelTopicStream =>
      _channelStateStream.map((state) => state?.topic).distinct();

  Future<RequestResult<bool>> leaveChannel(
          {bool waitForResult: false}) async =>
      await _backendService.leaveChannel(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<ChannelUser>> printUserInfo(String userNick,
          {bool waitForResult: false}) async =>
      await _backendService.requestUserInfo(network, channel, userNick,
          waitForResult: waitForResult);

  Future<RequestResult<ChatMessage>> printChannelBannedUsers(
          {bool waitForResult: false}) async =>
      await _backendService.printChannelBannedUsers(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> editChannelTopic(String newTopic,
          {bool waitForResult: false}) async =>
      await _backendService.editChannelTopic(network, channel, newTopic,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> onOpenChannel() async =>
      await _backendService.sendChannelOpenedEventToServer(network, channel);

  Future<RequestResult<ChatMessage>> sendChannelRawMessage(
          String rawMessage,
          {bool waitForResult: false}) async =>
      await _backendService.sendChannelRawMessage(
          network, channel, rawMessage,
          waitForResult: waitForResult);

  Future<RequestResult<ChannelWithState>> openDirectMessagesChannel(
          String nick) async =>
      await _backendService.openDirectMessagesChannel(network, channel, nick);

  static ChannelBloc of(BuildContext context) {
    return Provider.of<ChannelBlocProvider>(context).channelBloc;
  }

  Future<RequestResult<MessageListLoadMore>> loadMoreHistory(
      RegularMessage oldestMessage) async => await _backendService
      .loadMoreHistory(
        network, channel, oldestMessage?.messageRemoteId);

  Future<RequestResult<ToggleMessagePreviewData>> togglePreview(
      RegularMessage message, MessagePreview preview) {
    return _backendService.togglePreview(network, channel, message, preview);
  }
}
