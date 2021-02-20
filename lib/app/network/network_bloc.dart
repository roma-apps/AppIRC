import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_bloc_provider.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/app/network/state/network_states_bloc.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkBloc extends DisposableOwner {
  final ChatBackendService _backendService;
  final Network network;
  final NetworkStatesBloc _networksStateBloc;
  final ChannelStatesBloc _channelsStateBloc;
  final ChatActiveChannelBloc _activeChannelBloc;

  NetworkBloc(this._backendService, this.network, this._networksStateBloc,
      this._channelsStateBloc, this._activeChannelBloc);

  NetworkState get _networkState => _networksStateBloc.getNetworkState(network);

  Stream<NetworkState> get _networkStateStream =>
      _networksStateBloc.getNetworkStateStream(network);

  NetworkTitle get networkTitle =>
      NetworkTitle(_networkState.name, _networkState.nick);

  Stream<NetworkTitle> get networkTitleStream => _networkStateStream
      .map((state) => NetworkTitle(_networkState.name, _networkState.nick))
      .distinct();

  String get networkNick => _networkState.nick;

  Stream<String> get networkNickStream =>
      _networkStateStream.map((state) => state?.nick).distinct();

  String get networkName => _networkState.name;

  Stream<String> get networkNameStream =>
      _networkStateStream.map((state) => state?.name).distinct();

  bool get networkConnected => _networkState.connected;

  Stream<bool> get networkConnectedStream =>
      _networkStateStream.map((state) => state?.connected).distinct();

  Future<RequestResult<List<SpecialMessage>>> printNetworkAvailableChannels(
          {bool waitForResult = false}) async =>
      await _backendService.printNetworkAvailableChannels(network,
          waitForResult: waitForResult);

  Future<RequestResult<ChatMessage>> printNetworkIgnoredUsers(
          {bool waitForResult = false}) async =>
      await _backendService.printNetworkIgnoredUsers(network,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> enableNetwork(
          {bool waitForResult = false}) async =>
      await _backendService.enableNetwork(network,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> disableNetwork(
          {bool waitForResult = false}) async =>
      await _backendService.disableNetwork(network,
          waitForResult: waitForResult);

  Future<RequestResult<Network>> editNetworkSettings(
          NetworkPreferences preferences,
          {bool waitForResult = false}) async =>
      await _backendService.editNetworkSettings(network, preferences,
          waitForResult: waitForResult);

  Future<RequestResult<ChannelWithState>> joinChannel(
      ChannelPreferences preferences,
      {bool waitForResult = false}) async {
    var alreadyJoinedChannel = network.channels.firstWhere(
        (channel) => channel.name == preferences.name,
        orElse: () => null);

    if (alreadyJoinedChannel != null) {
      await _activeChannelBloc.changeActiveChanel(alreadyJoinedChannel);

      var channelState =
          _channelsStateBloc.getChannelState(network, alreadyJoinedChannel);
      var initMessages = <ChatMessage>[];
      var initUsers = <ChannelUser>[];
      return RequestResult.withResponse(ChannelWithState(
          alreadyJoinedChannel, channelState, initMessages, initUsers));
    } else {
      return await _backendService.joinChannel(network, preferences,
          waitForResult: waitForResult);
    }
  }

  Future<RequestResult<bool>> leaveNetwork({bool waitForResult = false}) async =>
      await _backendService.leaveNetwork(network, waitForResult: waitForResult);

  static NetworkBloc of(BuildContext context) {
    return Provider.of<NetworkBlocProvider>(context).networkBloc;
  }
}
