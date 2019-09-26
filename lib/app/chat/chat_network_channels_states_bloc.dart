import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworkChannelsStateBloc extends ChatNetworkChannelsBloc {
  final Map<String, Map<int, BehaviorSubject<NetworkChannelState>>> _states =
      Map();

  BehaviorSubject<NetworkChannelState> _getStateControllerForNetworkChannel(
      Network network, NetworkChannel channel) {
    var networkKey = _calculateNetworkKey(network);
    var channelKey = _calculateChannelKey(channel);
    if (!_states.containsKey(networkKey)) {
      _states[networkKey] = Map<int, BehaviorSubject<NetworkChannelState>>();
    }

    if (!_states[networkKey].containsKey(channelKey)) {
      _states[networkKey][channelKey] = BehaviorSubject<NetworkChannelState>(
          seedValue: NetworkChannelState.empty);
    }

    return _states[networkKey][_calculateChannelKey(channel)];
  }

  ChatActiveChannelBloc activeChannelBloc;

  ChatNetworkChannelsStateBloc(
      this.activeChannelBloc,
      ChatOutputBackendService backendService,
      ChatNetworksListBloc networksListBloc)
      : super(backendService, networksListBloc) {
    addDisposable(streamSubscription:
        networksListBloc.lastJoinedNetworkStream.listen((network) {
      onNetworkJoined(network);
    }));

    addDisposable(streamSubscription: activeChannelBloc.activeChannelStream.listen((newActiveChannel) {
      Network networkForChannel = networksListBloc.findNetworkWithChannel(newActiveChannel);

      var state = getNetworkChannelState(networkForChannel, newActiveChannel);
      state.unreadCount = 0;
      _updateState(networkForChannel, newActiveChannel, state);

    }));
  }

  void _updateState(
      Network network, NetworkChannel channel, NetworkChannelState state) {

    if(activeChannelBloc.activeChannel == channel) {
      state.unreadCount = 0;
    }

    _getStateControllerForNetworkChannel(network, channel).add(state);
  }

  String _calculateNetworkKey(Network network) => network.remoteId;

  int _calculateChannelKey(NetworkChannel channel) => channel.remoteId;

  Stream<NetworkChannelState> getNetworkChannelStateStream(
          Network network, NetworkChannel networkChannel) =>
      _states[_calculateNetworkKey(network)][networkChannel.remoteId].stream;

  NetworkChannelState getNetworkChannelState(
          Network network, NetworkChannel networkChannel) =>
      _states[_calculateNetworkKey(network)][networkChannel.remoteId].value;

  @override
  void onChannelJoined(
      Network network, NetworkChannel channel, NetworkChannelState state) {
    _updateState(network, channel, state);
    addDisposable(
        disposable: backendService.listenForNetworkChannelState(
            network,
            channel,
            () => _getStateControllerForNetworkChannel(network, channel).value,
            (state) {
      _updateState(network, channel, state);
    }));
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {

//    Future.delayed(Duration(microseconds:  1000), () {
      var stateController =
      _getStateControllerForNetworkChannel(network, channel);
      stateController.close();
      _states[_calculateNetworkKey(network)]
          .remove(_calculateChannelKey(channel));
//    });

  }
}
