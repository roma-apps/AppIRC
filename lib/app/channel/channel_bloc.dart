import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/messages/channel_messages_list_bloc.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/preview/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

final Duration _usersListOutDateDuration = Duration(seconds: 15);

class NetworkChannelBloc extends DisposableOwner implements MoreHistoryOwner {
  final ChatBackendService _backendService;
  final Network network;
  NetworkChannel _channel;
  NetworkChannel get channel => _channel;
  final ChatNetworkChannelsStateBloc _channelsStatesBloc;

  ChatInputMessageBloc _inputMessageBloc;

  ChannelMessagesListBloc _messagesBloc;

  ChannelMessagesListBloc get messagesBloc => _messagesBloc;

  ChatInputMessageBloc get inputMessageBloc => _inputMessageBloc;

  NetworkChannelBloc(this._backendService, this.network,
      NetworkChannelWithState channelWithState, this._channelsStatesBloc) {
    _channel = channelWithState.channel;
    _usersSubject =
        BehaviorSubject(seedValue: channelWithState.initUsers ?? []);

    _messagesBloc = ChannelMessagesListBloc();
    addDisposable(disposable: _messagesBloc);

    addDisposable(subject: _usersSubject);
    addDisposable(
        disposable: _backendService
            .listenForNetworkChannelNames(network, channel, (newUsers) {
      _usersSubject.add(newUsers);
    }));
    addDisposable(
        disposable:
            _backendService.listenForNetworkChannelUsers(network, channel, () {
      _backendService.requestNetworkChannelUsers(network, channel);
    }));
    _inputMessageBloc = ChatInputMessageBloc(_backendService.chatConfig, this);
    addDisposable(disposable: _inputMessageBloc);
  }

  // ignore: close_sinks
  BehaviorSubject<List<NetworkChannelUser>> _usersSubject;

  Stream<List<NetworkChannelUser>> get usersStream => _usersSubject.stream;

  List<NetworkChannelUser> get users => _usersSubject.value;
  DateTime _lastUsersRefreshDate;

  Future<List<NetworkChannelUser>> retrieveUsers({forceRefresh: false}) async {
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
    await _backendService.requestNetworkChannelUsers(network, channel,
        waitForResult: false);
  }

  NetworkChannelState get networkChannelState =>
      _channelsStatesBloc.getNetworkChannelState(network, channel);

  Stream<NetworkChannelState> get _networkChannelStateStream =>
      _channelsStatesBloc.getNetworkChannelStateStream(network, channel);

  bool get networkChannelConnected => networkChannelState.connected;

  Stream<bool> get networkChannelConnectedStream =>
      _networkChannelStateStream.map((state) => state?.connected).distinct();

  bool get networkChannelMoreHistoryAvailable =>
      networkChannelState?.moreHistoryAvailable;

  Stream<bool> get networkChannelMoreHistoryAvailableStream =>
      _networkChannelStateStream
          .map((state) => state?.moreHistoryAvailable)
          .distinct();

  int get networkChannelUnreadCount => networkChannelState.unreadCount;

  Stream<int> get networkChannelUnreadCountStream =>
      _networkChannelStateStream.map((state) => state?.unreadCount).distinct();

  String get networkChannelTopic => networkChannelState.topic;

  Stream<String> get networkChannelTopicStream =>
      _networkChannelStateStream.map((state) => state?.topic).distinct();

  Future<RequestResult<bool>> leaveNetworkChannel(
          {bool waitForResult: false}) async =>
      await _backendService.leaveNetworkChannel(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelUser>> printUserInfo(String userNick,
          {bool waitForResult: false}) async =>
      await _backendService.requestUserInfo(network, channel, userNick,
          waitForResult: waitForResult);

  Future<RequestResult<ChatMessage>> printNetworkChannelBannedUsers(
          {bool waitForResult: false}) async =>
      await _backendService.printNetworkChannelBannedUsers(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> editNetworkChannelTopic(String newTopic,
          {bool waitForResult: false}) async =>
      await _backendService.editNetworkChannelTopic(network, channel, newTopic,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> onOpenNetworkChannel() async =>
      await _backendService.sendChannelOpenedEventToServer(network, channel);

  Future<RequestResult<ChatMessage>> sendNetworkChannelRawMessage(
          String rawMessage,
          {bool waitForResult: false}) async =>
      await _backendService.sendNetworkChannelRawMessage(
          network, channel, rawMessage,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelWithState>> openDirectMessagesChannel(
          String nick) async =>
      await _backendService.openDirectMessagesChannel(network, channel, nick);

  static NetworkChannelBloc of(BuildContext context) {
    return Provider.of<NetworkChannelBlocProvider>(context).networkChannelBloc;
  }

  Future<RequestResult<ChatLoadMoreData>> loadMoreHistory(
      RegularMessage oldestMessage) async {
    return _backendService.loadMoreHistory(
        network, channel, oldestMessage.messageRemoteId);
  }

  Future<RequestResult<MessageTogglePreview>> togglePreview(
      RegularMessage message, MessagePreview preview) {
    return _backendService.togglePreview(network, channel, message, preview);
  }
}
