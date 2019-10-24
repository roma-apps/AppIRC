import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/state/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworkChannelsStateBloc extends ChatNetworkChannelsListListenerBloc {
  final Map<String, Map<int, BehaviorSubject<NetworkChannelState>>> _statesMap =
      Map();
  List<NetworkChannelState> get states {
    var states = <NetworkChannelState>[];
    _statesMap.values.forEach((Map<int, BehaviorSubject<NetworkChannelState>>
    entry) {
      states.addAll(entry.values.map((subject) => subject.value));

    });
    return states;
  }

  // ignore: close_sinks
  final BehaviorSubject _anyStateChangedController = BehaviorSubject();
  Stream get anyStateChangedStream => _anyStateChangedController.stream;

  final ChatActiveChannelBloc activeChannelBloc;
  final ChatOutputBackendService backendService;

  ChatNetworkChannelsStateBloc(
    this.backendService,
    ChatNetworksListBloc networksListBloc,
    this.activeChannelBloc,
  ) : super(networksListBloc) {
    addDisposable(subject: _anyStateChangedController);
    addDisposable(streamSubscription:
        activeChannelBloc.activeChannelStream.listen((newActiveChannel) {
      Network networkForChannel =
          networksListBloc.findNetworkWithChannel(newActiveChannel);

      var state = getNetworkChannelState(networkForChannel, newActiveChannel);
      state.unreadCount = 0;
      _updateState(networkForChannel, newActiveChannel, state);
    }));
  }

  BehaviorSubject<NetworkChannelState> _getStateControllerForNetworkChannel(
      Network network, NetworkChannel channel) {
    var networkKey = _calculateNetworkKey(network);
    var channelKey = _calculateChannelKey(channel);
    if (!_statesMap.containsKey(networkKey)) {
      _statesMap[networkKey] = Map<int, BehaviorSubject<NetworkChannelState>>();
    }

    if (!_statesMap[networkKey].containsKey(channelKey)) {
      _statesMap[networkKey][channelKey] = BehaviorSubject<NetworkChannelState>(
          seedValue: NetworkChannelState.empty);
    }

    return _statesMap[networkKey][_calculateChannelKey(channel)];
  }

  void _updateState(
      Network network, NetworkChannel channel, NetworkChannelState state) {
    if (activeChannelBloc.activeChannel == channel) {
      state.unreadCount = 0;
    }

    _getStateControllerForNetworkChannel(network, channel).add(state);


    _anyStateChangedController.add(null);
  }

  String _calculateNetworkKey(Network network) => network.remoteId;

  int _calculateChannelKey(NetworkChannel channel) => channel.remoteId;

  Stream<NetworkChannelState> getNetworkChannelStateStream(
          Network network, NetworkChannel networkChannel) =>
      _statesMap[_calculateNetworkKey(network)][networkChannel.remoteId].stream;

  NetworkChannelState getNetworkChannelState(
          Network network, NetworkChannel networkChannel) =>
      _statesMap[_calculateNetworkKey(network)][networkChannel.remoteId].value;

  @override
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState) {
    var channel = channelWithState.channel;
    var state = channelWithState.state;
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
    _statesMap[_calculateNetworkKey(network)]
        .remove(_calculateChannelKey(channel));
//    });
  }
}
