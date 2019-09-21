import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class NetworkChannelBloc extends Providable {
  final ChatInputOutputBackendService backendService;
  final Network network;
  final NetworkChannel channel;
  final ChatNetworkChannelsStateBloc channelsStatesBloc;

  // ignore: close_sinks
  final BehaviorSubject<List<ChannelUserInfo>> _usersController = BehaviorSubject();
   Stream<List<ChannelUserInfo>> get usersStream => _usersController.stream;
   List<ChannelUserInfo> get users => _usersController.value;

  NetworkChannelState get networkChannelState =>
      channelsStatesBloc.getNetworkChannelState(network, channel);

  Stream<NetworkChannelState> get networkChannelStateStream =>
      channelsStatesBloc.getNetworkChannelStateStream(network, channel);

  NetworkChannelBloc(
      this.backendService, this.network, this.channel, this.channelsStatesBloc) {
    addDisposable(subject: _usersController);
    addDisposable(disposable: backendService.listenForNetworkChannelUsers(network, channel, (newUsers) {
      _usersController.add(newUsers);
    }));
  }

  get messagesStream =>
      channelsStatesBloc.getMessagesBloc(network, channel).messagesStream;

  Future<RequestResult<bool>> leaveNetworkChannel(
          {bool waitForResult: false}) async =>
      await backendService.leaveNetworkChannel(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<ChannelUserInfo>> getUserInfo(String userNick,
          {bool waitForResult: false}) async =>
      await backendService.getUserInfo(network, channel, userNick,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelMessage>> printNetworkChannelBannedUsers(
          {bool waitForResult: false}) async =>
      await backendService.printNetworkChannelBannedUsers(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<List<ChannelUserInfo>>> getNetworkChannelUsers(
          {bool waitForResult: false}) async =>
      await backendService.getNetworkChannelUsers(network, channel,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> editNetworkChannelTopic(String newTopic,
          {bool waitForResult: false}) async =>
      await backendService.editNetworkChannelTopic(network, channel, newTopic,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> onOpenNetworkChannel() async =>
      await backendService.onOpenNetworkChannel(network, channel);

  Future<RequestResult<NetworkChannelMessage>> sendNetworkChannelRawMessage(
          String rawMessage,
          {bool waitForResult: false}) async =>
      await backendService.sendNetworkChannelRawMessage(
          network, channel, rawMessage,
          waitForResult: waitForResult);
}
