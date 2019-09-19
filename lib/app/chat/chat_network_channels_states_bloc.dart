import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_messages_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworkChannelsStateBloc extends Providable {
  final ChatOutputBackendService backendService;
  final ChatNetworksListBloc networksListBloc;

  final Map<Network, Map<NetworkChannel, BehaviorSubject<NetworkChannelState>>>
      _states =
      Map<Network, Map<NetworkChannel, BehaviorSubject<NetworkChannelState>>>();

  final Map<NetworkChannel, NetworkChannelMessagesBloc> _messagesBlocs =
      Map<NetworkChannel, NetworkChannelMessagesBloc>();

  NetworkChannelMessagesBloc getMessagesBloc(NetworkChannel channel) =>
      _messagesBlocs[channel];

  ChatNetworkChannelsStateBloc(this.backendService, this.networksListBloc) {
    addDisposable(streamSubscription:
        networksListBloc.lastJoinedNetworkStream.listen((network) {
      onNetworkJoined(network);
    }));
  }

  void onNetworkJoined(Network network) {
    var networkChannelListBloc =
        networksListBloc.getChatNetworkChannelsListBloc(network);

    _states[network] =
        Map<NetworkChannel, BehaviorSubject<NetworkChannelState>>();

    network.channels.forEach((channel) =>
        _onChannelJoined(networkChannelListBloc, network, channel));

    var lastJoinedListener =
        networkChannelListBloc.lastJoinedNetworkChannelStream.listen((channel) {
      _onChannelJoined(networkChannelListBloc, network, channel);
    });

    addDisposable(streamSubscription: lastJoinedListener);

    addDisposable(
        disposable: backendService.listenForNetworkExit(network, () {
      onNetworkExit(network);
      lastJoinedListener.cancel();
    }));
  }

  void _onChannelJoined(ChatNetworkChannelsListBloc bloc, Network network,
      NetworkChannel channel) {
    _states[network][channel] = BehaviorSubject<NetworkChannelState>(seedValue: NetworkChannelState.empty);
    _messagesBlocs[channel] =
        NetworkChannelMessagesBloc(backendService, network, channel);
    addDisposable(
        disposable: backendService
            .listenForNetworkChannelState(network, channel, (state) {
      _states[network][channel].add(state);
    }));

    StreamSubscription exitListener;
    exitListener = bloc.lastExitedNetworkChannelStream.listen((channel) {
      _states[network].remove(channel).close();
      _messagesBlocs.remove(channel).dispose();
      exitListener.cancel();
    });

    addDisposable(streamSubscription: exitListener);
  }

  void onNetworkExit(Network network) {
    _states.remove(network).forEach((channel, subject) {
      getMessagesBloc(channel).dispose();
      return subject.close();
    });
  }

  Stream<NetworkChannelState> getNetworkChannelStateStream(
          Network network, NetworkChannel networkChannel) =>
      _states[network][networkChannel].stream;

  NetworkChannelState getNetworkChannelState(
          Network network, NetworkChannel networkChannel) =>
      _states[network][networkChannel].value;
}
