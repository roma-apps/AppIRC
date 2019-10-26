import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/messages/channel_messages_list_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/preview/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

/// It is not possible to simple use NetworkChannelBloc as Provider
/// app shouldn't dispose NetworkChannelBloc instances during UI changes
/// NetworkChannelBloc disposed in ChatNetworkChannelsBlocsBloc
class NetworkChannelBlocProvider extends Providable {
  NetworkChannelBloc networkChannelBloc;
  NetworkChannelBlocProvider(this.networkChannelBloc);
}

final Duration usersListOutDateDuration = Duration(seconds: 15);

class NetworkChannelBloc extends DisposableOwner implements MoreHistoryOwner {
  final ChatBackendService backendService;
  final Network network;
  NetworkChannel channel;
  final ChatNetworkChannelsStateBloc channelsStatesBloc;

  ChatInputMessageBloc _inputMessageBloc;

  ChannelMessagesListBloc messagesBloc;

  ChatInputMessageBloc get inputMessageBloc => _inputMessageBloc;

  NetworkChannelBloc(this.backendService, this.network,
      NetworkChannelWithState channelWithState, this.channelsStatesBloc) {
    channel = channelWithState.channel;
    _usersController =
        BehaviorSubject(seedValue: channelWithState.initUsers ?? []);

    messagesBloc = ChannelMessagesListBloc();
    addDisposable(disposable: messagesBloc);

    addDisposable(subject: _usersController);
    addDisposable(disposable: backendService.listenForNetworkChannelNames(
        network, channel, (newUsers) {
      _usersController.add(newUsers);
    }));
    addDisposable(disposable: backendService.listenForNetworkChannelUsers(
        network, channel, () {
      backendService.requestNetworkChannelUsers(network, channel);
    }));
    _inputMessageBloc = ChatInputMessageBloc(backendService.chatConfig, this);
    addDisposable(disposable: _inputMessageBloc);
  }

  // ignore: close_sinks
  BehaviorSubject<List<NetworkChannelUser>> _usersController;

  Stream<List<NetworkChannelUser>> get usersStream => _usersController.stream;

  List<NetworkChannelUser> get users => _usersController.value;
  DateTime _lastUsersRefreshDate;

  Future<List<NetworkChannelUser>> getUsers({forceRefresh: false}) async {
    if (forceRefresh || _lastUsersRefreshDate == null) {
      await refreshUsers();
    } else {
      var now = DateTime.now();

      var differenceDuration = now.difference(_lastUsersRefreshDate);
      if (differenceDuration > usersListOutDateDuration) {
        refreshUsers();
      }
    }

    return _usersController.value;
  }

  refreshUsers() async {
    _lastUsersRefreshDate = DateTime.now();
    await backendService.requestNetworkChannelUsers(
        network, channel, waitForResult: false);
  }

  NetworkChannelState get networkChannelState =>
      channelsStatesBloc.getNetworkChannelState(network, channel);

  Stream<NetworkChannelState> get _networkChannelStateStream =>
      channelsStatesBloc.getNetworkChannelStateStream(network, channel);

  bool get networkChannelConnected => networkChannelState.connected;

  Stream<bool> get networkChannelConnectedStream =>
      _networkChannelStateStream.map((state) => state?.connected).distinct();

  bool get networkChannelMoreHistoryAvailable =>
      networkChannelState?.moreHistoryAvailable;

  Stream<bool> get networkChannelMoreHistoryAvailableStream =>
      _networkChannelStateStream.map((state) => state?.moreHistoryAvailable)
          .distinct();

  int get networkChannelUnreadCount => networkChannelState.unreadCount;

  Stream<int> get networkChannelUnreadCountStream =>
      _networkChannelStateStream.map((state) => state?.unreadCount).distinct();

  String get networkChannelTopic => networkChannelState.topic;

  Stream<String> get networkChannelTopicStream =>
      _networkChannelStateStream.map((state) => state?.topic).distinct();

  Future<RequestResult<bool>> leaveNetworkChannel(
      {bool waitForResult: false}) async =>
      await backendService.leaveNetworkChannel(
          network, channel, waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelUser>> printUserInfo(String userNick,
      {bool waitForResult: false}) async =>
      await backendService.requestUserInfo(
          network, channel, userNick, waitForResult: waitForResult);

  Future<RequestResult<ChatMessage>> printNetworkChannelBannedUsers(
      {bool waitForResult: false}) async =>
      await backendService.printNetworkChannelBannedUsers(
          network, channel, waitForResult: waitForResult);

//  Future<RequestResult<List<ChannelUserInfo>>> getNetworkChannelUsers(
//          {bool waitForResult: false}) async =>
//      await backendService.getNetworkChannelUsers(network, channel,
//          waitForResult: waitForResult);

  Future<RequestResult<bool>> editNetworkChannelTopic(String newTopic,
      {bool waitForResult: false}) async =>
      await backendService.editNetworkChannelTopic(
          network, channel, newTopic, waitForResult: waitForResult);

  Future<RequestResult<bool>> onOpenNetworkChannel() async =>
      await backendService.sendChannelOpenedEventToServer(network, channel);

  Future<RequestResult<ChatMessage>> sendNetworkChannelRawMessage(
      String rawMessage, {bool waitForResult: false}) async =>
      await backendService.sendNetworkChannelRawMessage(
          network, channel, rawMessage, waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelWithState>> openDirectMessagesChannel(
      String nick) async =>
      await backendService.openDirectMessagesChannel(network, channel, nick);

  static NetworkChannelBloc of(BuildContext context) {
    return Provider
        .of<NetworkChannelBlocProvider>(context)
        .networkChannelBloc;
  }

  Future<RequestResult<ChatLoadMoreData>> loadMoreHistory(
      RegularMessage oldestMessage) async {
    return backendService.loadMoreHistory(network, channel, oldestMessage.messageRemoteId);
  }

  Future<RequestResult<MessageTogglePreview>> togglePreview(RegularMessage message,
      MessagePreview preview) {
    return backendService.togglePreview(network, channel, message, preview);
  }


}

