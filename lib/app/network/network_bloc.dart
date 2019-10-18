
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';



/// It is not possible to simple use NetworkBloc as Provider
/// app shouldn't dispose NetworkBloc instances during UI changes
/// NetworkBloc disposed in ChatNetworksBlocsBloc
class NetworkBlocProvider extends Providable {
  NetworkBloc networkBloc;
  NetworkBlocProvider(this.networkBloc);


}

class NetworkBloc extends DisposableOwner {
  final ChatInputBackendService backendService;
  final Network network;
  final ChatNetworksStateBloc networksStateBloc;
  final ChatNetworkChannelsStateBloc channelsStateBloc;
  final ChatActiveChannelBloc activeChannelBloc;

  NetworkState get networkState => networksStateBloc.getNetworkState(network);

  Stream<NetworkState> get networkStateStream =>
      networksStateBloc.getNetworkStateStream(network);

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
