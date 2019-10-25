import 'dart:ui';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworkChannelsListBloc extends Providable {
  final ChatOutputBackendService backendService;
  final Network network;
  final LocalIdGenerator nextChannelIdGenerator;

  int get _nextNetworkChannelLocalId => nextChannelIdGenerator();

  ChatNetworkChannelsListBloc(
      this.backendService,
      this.network,
      List<NetworkChannelWithState> startChannelsWithState,
      this.nextChannelIdGenerator) {
    addDisposable(subject: _networksChannelsController);

    _onChannelsChanged(network.channels);

    for (var channelWithState in startChannelsWithState) {

      _onChannelJoined(channelWithState);
    }

    var listenForNetworkChannelJoin = backendService
        .listenForNetworkChannelJoin(network, (channelWithState) async {
      var channel = channelWithState.channel;

      network.channels.add(channel);

      _onChannelsChanged(network.channels);

      _onChannelJoined(channelWithState);
    });

    addDisposable(disposable: listenForNetworkChannelJoin);
  }

  void _onChannelJoined(NetworkChannelWithState channelWithState) {

    var channel = channelWithState.channel;

    if (channel.localId == null) {
      channel.localId = _nextNetworkChannelLocalId;
    }

    joinListeners.forEach((listener) => listener(channelWithState));

    Disposable listenForNetworkChannelLeave;

    listenForNetworkChannelLeave =
        backendService.listenForNetworkChannelLeave(network, channel, () async {


      var tempListeners = <VoidCallback>[];
      // additional list required
      // because we want modify original list during iteration
      var originalListeners = leaveListeners[channel];
      tempListeners.addAll(originalListeners);
      tempListeners.forEach((listener) {
        listener();
      });

      // all listeners should dispose itself on leave
      assert(originalListeners.isEmpty);

      network.channels.remove(channel);

      _onChannelsChanged(network.channels);

      listenForNetworkChannelLeave.dispose();
    });
    addDisposable(disposable: listenForNetworkChannelLeave);
  }

  void _onChannelsChanged(List<NetworkChannel> networkChannels) {
    _networksChannelsController.add(networkChannels);
  }

  List<NetworkChannel> get networkChannels => _networksChannelsController.value;

  Stream<List<NetworkChannel>> get networkChannelsStream =>
      _networksChannelsController.stream;

  // ignore: close_sinks
  var _networksChannelsController =
      BehaviorSubject<List<NetworkChannel>>(seedValue: []);


  final List<NetworkChannelListener> joinListeners = [];
  final Map<NetworkChannel, List<VoidCallback>> leaveListeners = Map();

  Disposable listenForNetworkChannelJoin(NetworkChannelListener listener) {

    joinListeners.add(listener);
    return CustomDisposable(() {
      joinListeners.remove(listener);
    });
  }

  Disposable listenForNetworkChannelLeave(NetworkChannel channel, VoidCallback listener) {


    if(!leaveListeners.containsKey(channel)) {
      leaveListeners[channel] = [];
    }
    leaveListeners[channel].add(listener);
    return CustomDisposable(() {
      leaveListeners[channel].remove(listener);
    });
  }
}
