
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/chat/state/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/special/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/provider/provider.dart';



/// It is not possible to simple use NetworkBloc as Provider
/// app shouldn't dispose NetworkBloc instances during UI changes
/// NetworkBloc disposed in ChatNetworksBlocsBloc
class NetworkBlocProvider extends Providable {
  NetworkBloc networkBloc;
  NetworkBlocProvider(this.networkBloc);


}

class NetworkTitle {
  String name;
  String nick;
  NetworkTitle(this.name, this.nick);


}

class NetworkBloc extends DisposableOwner {
  final ChatBackendService backendService;
  final Network network;
  final ChatNetworksStateBloc networksStateBloc;
  final ChatNetworkChannelsStateBloc channelsStateBloc;
  final ChatActiveChannelBloc activeChannelBloc;

  NetworkState get _networkState => networksStateBloc.getNetworkState(network);

  Stream<NetworkState> get _networkStateStream =>
      networksStateBloc.getNetworkStateStream(network);


  NetworkTitle get networkTitle => NetworkTitle(_networkState.name,
    _networkState.nick);
  Stream<NetworkTitle> get networkTitleStream => _networkStateStream.map(
          (state) => NetworkTitle(_networkState.name,
              _networkState.nick)).distinct();
  
  String get networkNick => _networkState.nick;

  Stream<String> get networkNickStream => _networkStateStream.map((state) =>
  state?.nick).distinct();
  
  String get networkName => _networkState.name;

  Stream<String> get networkNameStream => _networkStateStream.map((state) =>
  state?.name).distinct();
  
  bool get networkConnected => _networkState.connected;

  Stream<bool> get networkConnectedStream => _networkStateStream.map(
          (state) => state?.connected).distinct();

  NetworkBloc(this.backendService, this.network, this.networksStateBloc,
      this.channelsStateBloc, this.activeChannelBloc);

  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
          {bool waitForResult: false}) async =>
      await backendService.printNetworkAvailableChannels(network,
          waitForResult: waitForResult);

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(
          {bool waitForResult: false}) async =>
      await backendService.printNetworkIgnoredUsers(network,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> enableNetwork(
          {bool waitForResult: false}) async =>
      await backendService.enableNetwork(network, waitForResult: waitForResult);

  Future<RequestResult<bool>> disableNetwork(
          {bool waitForResult: false}) async =>
      await backendService.disableNetwork(network,
          waitForResult: waitForResult);

  Future<RequestResult<Network>> editNetworkSettings(
          ChatNetworkPreferences preferences,
          {bool waitForResult: false}) async =>
      await backendService.editNetworkSettings(network, preferences,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelWithState>> joinNetworkChannel(
      ChatNetworkChannelPreferences preferences,
      {bool waitForResult: false}) async {
    var alreadyJoinedChannel = network.channels.firstWhere(
        (channel) => channel.name == preferences.name,
        orElse: () => null);

    if (alreadyJoinedChannel != null) {
      activeChannelBloc.changeActiveChanel(alreadyJoinedChannel);

      var channelState = channelsStateBloc.getNetworkChannelState(
          network, alreadyJoinedChannel);
      var initMessages = <ChatMessage>[];
      var initUsers = <NetworkChannelUser>[];
      return RequestResult<NetworkChannelWithState>(
          true, NetworkChannelWithState(alreadyJoinedChannel, channelState,
        initMessages, initUsers));
    } else {
      return await backendService.joinNetworkChannel(network, preferences,
          waitForResult: waitForResult);
    }
  }

  Future<RequestResult<bool>> leaveNetwork({bool waitForResult: false}) async =>
      await backendService.leaveNetwork(network, waitForResult: waitForResult);

   static NetworkBloc of(BuildContext context) {
    return Provider.of<NetworkBlocProvider>(context).networkBloc;
  }

}
