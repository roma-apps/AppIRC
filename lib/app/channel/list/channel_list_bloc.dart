import 'dart:ui';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChannelListBloc extends Providable {
  final ChatBackendService _backendService;
  final Network network;
  final LocalIdGenerator _nextChannelIdGenerator;

  List<Channel> get channels => _networksChannelsSubject.value;

  Stream<List<Channel>> get channelsStream =>
      _networksChannelsSubject.stream;

  // ignore: close_sinks
  var _networksChannelsSubject =
      BehaviorSubject<List<Channel>>(seedValue: []);

  final List<ChannelListener> _joinListeners = [];
  final Map<Channel, List<VoidCallback>> _leaveListeners = Map();

  int get _nextChannelLocalId => _nextChannelIdGenerator();

  ChannelListBloc(
      this._backendService,
      this.network,
      List<ChannelWithState> startChannelsWithState,
      this._nextChannelIdGenerator) {
    addDisposable(subject: _networksChannelsSubject);

    _onChannelsChanged(network.channels);

    for (var channelWithState in startChannelsWithState) {
      _onChannelJoined(channelWithState);
    }

    var listenForChannelJoin = _backendService
        .listenForChannelJoin(network, (channelWithState) async {
      var channel = channelWithState.channel;

      network.channels.add(channel);

      _onChannelsChanged(network.channels);

      _onChannelJoined(channelWithState);
    });

    addDisposable(disposable: listenForChannelJoin);
  }

  void _onChannelJoined(ChannelWithState channelWithState) {
    var channel = channelWithState.channel;

    if (channel.localId == null) {
      channel.localId = _nextChannelLocalId;
    }

    _joinListeners.forEach((listener) => listener(channelWithState));

    Disposable listenForChannelLeave;

    listenForChannelLeave = _backendService
        .listenForChannelLeave(network, channel, () async {
      var tempListeners = <VoidCallback>[];
      // additional list required
      // because we want modify original list during iteration
      var originalListeners = _leaveListeners[channel];
      tempListeners.addAll(originalListeners);
      tempListeners.forEach((listener) {
        listener();
      });

      // all listeners should dispose itself on leave
      assert(originalListeners.isEmpty);

      network.channels.remove(channel);

      _onChannelsChanged(network.channels);

      listenForChannelLeave.dispose();
    });
    addDisposable(disposable: listenForChannelLeave);
  }

  void _onChannelsChanged(List<Channel> channels) {
    _networksChannelsSubject.add(channels);
  }

  Disposable listenForChannelJoin(ChannelListener listener) {
    _joinListeners.add(listener);
    return CustomDisposable(() {
      _joinListeners.remove(listener);
    });
  }

  Disposable listenForChannelLeave(
      Channel channel, VoidCallback listener) {
    if (!_leaveListeners.containsKey(channel)) {
      _leaveListeners[channel] = [];
    }
    _leaveListeners[channel].add(listener);
    return CustomDisposable(() {
      _leaveListeners[channel].remove(listener);
    });
  }
}
