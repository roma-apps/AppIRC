import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class ChatNetworkChannelsBloc extends Providable {
  final ChatOutputBackendService backendService;
  final ChatNetworksListBloc networksListBloc;



  ChatNetworkChannelsBloc(this.backendService, this.networksListBloc) {
    addDisposable(streamSubscription:
        networksListBloc.lastJoinedNetworkStream.listen((network) {
      onNetworkJoined(network);
    }));
  }

  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;

    networkWithState.channelsWithState.forEach((channelWithState) =>
        _$onChannelJoined(
            network, channelWithState.channel, channelWithState.state));

    var lastJoinedListener = backendService.listenForNetworkChannelJoin(network,
        ((channelWithState) {
      _$onChannelJoined(
          network, channelWithState.channel, channelWithState.state);
    }));

    addDisposable(disposable: lastJoinedListener);

    addDisposable(
        disposable: backendService.listenForNetworkExit(network, () {
      onNetworkExit(network);
      lastJoinedListener.dispose();
    }));
  }

  void _$onChannelJoined(
      Network network, NetworkChannel channel, NetworkChannelState state) {
    onChannelJoined(network, channel, state);


    Disposable exitListener;
    exitListener =
        backendService.listenForNetworkChannelLeave(network, channel, () {
      onChannelLeaved(network, channel);
      exitListener.dispose();
    });

    addDisposable(disposable: exitListener);
  }

  @protected
  void onChannelLeaved(Network network, NetworkChannel channel);
  @protected
  void onChannelJoined(Network network, NetworkChannel channel, NetworkChannelState state);

  void onNetworkExit(Network network) {
    network.channels.forEach((channel) =>  onChannelLeaved(network, channel));
  }


}
