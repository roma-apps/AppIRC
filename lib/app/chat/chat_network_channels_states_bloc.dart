import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_messages_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworkChannelsStateBloc extends Providable {
  final ChatOutputBackendService backendService;
  final ChatNetworksListBloc networksListBloc;

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

  final Map<int, NetworkChannelMessagesBloc> _messagesBlocs = Map();

  NetworkChannelMessagesBloc getMessagesBloc(
      Network network, NetworkChannel channel) {
    var channelKey = channel.remoteId;
    if (!_messagesBlocs.containsKey(channelKey)) {
      _messagesBlocs[channelKey] =
          NetworkChannelMessagesBloc(backendService, network, channel);
    }
    return _messagesBlocs[channelKey];
  }

  ChatNetworkChannelsStateBloc(this.backendService, this.networksListBloc) {
    addDisposable(streamSubscription:
        networksListBloc.lastJoinedNetworkStream.listen((network) {
      onNetworkJoined(network);
    }));
  }

  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;

    networkWithState.channelsWithState.forEach((channelWithState) =>
        _onChannelJoined(
            network, channelWithState.channel, channelWithState.state));

    var lastJoinedListener = backendService.listenForNetworkChannelJoin(network,
        ((channelWithState) {
      _onChannelJoined(
          network, channelWithState.channel, channelWithState.state);
    }));

    addDisposable(disposable: lastJoinedListener);

    addDisposable(
        disposable: backendService.listenForNetworkExit(network, () {
      onNetworkExit(network);
      lastJoinedListener.dispose();
    }));
  }

  void _onChannelJoined(
      Network network, NetworkChannel channel, NetworkChannelState state) {
    _updateState(network, channel, state);
    addDisposable(
        disposable: backendService.listenForNetworkChannelState(
            network, channel, () => _states[network][channel].value, (state) {
      _updateState(network, channel, state);
    }));

    Disposable exitListener;
    exitListener =
        backendService.listenForNetworkChannelLeave(network, channel, () {
      _onChannelLeave(network, channel);
      exitListener.dispose();
    });

    addDisposable(disposable: exitListener);
  }

  void _onChannelLeave(Network network, NetworkChannel channel) {
    var stateController =
        _getStateControllerForNetworkChannel(network, channel);
    stateController.close();
    _states[_calculateNetworkKey(network)]
        .remove(_calculateChannelKey(channel));
    _messagesBlocs.remove(_calculateChannelKey(channel)).dispose();
  }

  void _updateState(
      Network network, NetworkChannel channel, NetworkChannelState state) {
    _getStateControllerForNetworkChannel(network, channel).add(state);
  }

  String _calculateNetworkKey(Network network) => network.remoteId;

  int _calculateChannelKey(NetworkChannel channel) => channel.remoteId;

  void onNetworkExit(Network network) {
    if (_states.containsKey(_calculateNetworkKey(network))) {
      _states
          .remove(_calculateNetworkKey(network))
          .forEach((remoteChannelId, subject) {
        if (_messagesBlocs.containsKey(remoteChannelId)) {
          _messagesBlocs[remoteChannelId].dispose();
        }

        subject.close();
      });
    }
  }

  Stream<NetworkChannelState> getNetworkChannelStateStream(
          Network network, NetworkChannel networkChannel) =>
      _states[_calculateNetworkKey(network)][networkChannel.remoteId].stream;

  NetworkChannelState getNetworkChannelState(
          Network network, NetworkChannel networkChannel) =>
      _states[_calculateNetworkKey(network)][networkChannel.remoteId].value;
}
