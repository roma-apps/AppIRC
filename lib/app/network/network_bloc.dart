import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

import 'network_model.dart';

class NetworkBloc extends Providable {
  final ChatInputBackendService backendService;
  final Network network;
  final ChatNetworksStateBloc networksStateBloc;

  NetworkState get networkState => networksStateBloc.getNetworkState(network);

  Stream<NetworkState> get networkStateStream =>
      networksStateBloc.getNetworkStateStream(network);

  NetworkBloc(this.backendService, this.network, this.networksStateBloc);

  Future<RequestResult<List<IRCChatSpecialMessage>>>
      printNetworkAvailableChannels({bool waitForResult: false}) async =>
          await backendService.printNetworkAvailableChannels(network,
              waitForResult: waitForResult);

  Future<RequestResult<NetworkChannelMessage>> printNetworkIgnoredUsers(
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
          IRCNetworkPreferences preferences,
          {bool waitForResult: false}) async =>
      await backendService.editNetworkSettings(network, preferences,
          waitForResult: waitForResult);

  Future<RequestResult<NetworkChannel>> joinNetworkChannel(
          IRCNetworkChannelPreferences preferences,
          {bool waitForResult: false}) async =>
      await backendService.joinNetworkChannel(network, preferences,
          waitForResult: waitForResult);
}
