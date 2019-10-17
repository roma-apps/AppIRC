import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class NetworkChannelBloc extends Providable {
  final ChatInputOutputBackendService backendService;
  final Network network;
  NetworkChannel channel;
  final ChatNetworkChannelsStateBloc channelsStatesBloc;

  ChatInputMessageBloc _inputMessageBloc;

  ChatInputMessageBloc get inputMessageBloc => _inputMessageBloc;

  NetworkChannelBloc(this.backendService, this.network,
      NetworkChannelWithState channelWithState, this.channelsStatesBloc) {
    channel = channelWithState.channel;
    _usersController =
        BehaviorSubject(seedValue: channelWithState.initUsers ?? []);

    addDisposable(subject: _usersController);
    addDisposable(
        disposable: backendService
            .listenForNetworkChannelNames(network, channel, (newUsers) {
      _usersController.add(newUsers);
    }));
    addDisposable(
        disposable:
            backendService.listenForNetworkChannelUsers(network, channel, () {
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

      var difference = now.difference(_lastUsersRefreshDate);
      // todo: change constant
      if (difference.inSeconds > 15) {
        refreshUsers();
      }
    }

    return _usersController.value;
  }

  refreshUsers() async {
    _lastUsersRefreshDate = DateTime.now();
    await backendService.requestNetworkChannelUsers(network, channel,
        waitForResult: false);
  }

  NetworkChannelState get networkChannelState =>
      channelsStatesBloc.getNetworkChannelState(network, channel);

  Stream<NetworkChannelState> get networkChannelStateStream =>
      channelsStatesBloc.getNetworkChannelStateStream(network, channel);

  Future<RequestResult<bool>> leaveNetworkChannel(
          {bool waitForResult: false}) async =>
      await backendService.leaveNetworkChannel(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelUser>> printUserInfo(String userNick,
          {bool waitForResult: false}) async =>
      await backendService.printUserInfo(network, channel, userNick,
          waitForResult: waitForResult);

  Future<RequestResult<ChatMessage>> printNetworkChannelBannedUsers(
          {bool waitForResult: false}) async =>
      await backendService.printNetworkChannelBannedUsers(network, channel,
          waitForResult: waitForResult);

//  Future<RequestResult<List<ChannelUserInfo>>> getNetworkChannelUsers(
//          {bool waitForResult: false}) async =>
//      await backendService.getNetworkChannelUsers(network, channel,
//          waitForResult: waitForResult);

  Future<RequestResult<bool>> editNetworkChannelTopic(String newTopic,
          {bool waitForResult: false}) async =>
      await backendService.editNetworkChannelTopic(network, channel, newTopic,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> onOpenNetworkChannel() async =>
      await backendService.onOpenNetworkChannel(network, channel);

  Future<RequestResult<ChatMessage>> sendNetworkChannelRawMessage(
          String rawMessage,
          {bool waitForResult: false}) async =>
      await backendService.sendNetworkChannelRawMessage(
          network, channel, rawMessage,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelWithState>> openDirectMessagesChannel(
          String nick) async =>
      await backendService.openDirectMessagesChannel(network, channel, nick);

  static NetworkChannelBloc of(BuildContext context, NetworkChannel channel) =>
      Provider.of<ChatNetworkChannelsBlocsBloc>(context)
          .getNetworkChannelBloc(channel);
}
