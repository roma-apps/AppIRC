import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/subjects.dart';

typedef LocalIdGenerator = int Function();

class NetworkListBloc extends Providable {
  final LocalIdGenerator nextChannelIdGenerator;
  final LocalIdGenerator nextNetworkIdGenerator;
  final ChatBackendService backendService;

  final Map<Network, ChannelListBloc> _networksChannelListBlocs =
      <Network, ChannelListBloc>{};

  ChannelListBloc getChannelListBloc(Network network) =>
      _networksChannelListBlocs[network];

  NetworkListBloc(this.backendService,
      {@required this.nextNetworkIdGenerator,
      @required this.nextChannelIdGenerator}) {
    addDisposable(subject: _networksSubject);

    addDisposable(
      disposable: backendService.listenForNetworkJoin(
        (networkWithState) {
          onNetworkJoined(networkWithState);
        },
      ),
    );
  }

  Future onNetworkJoined(NetworkWithState networkWithState) async {
    var network = networkWithState.network;

    network.localId ??= await _nextNetworkLocalId;
    for (var channel in network.channels) {
      channel.localId ??= await _nextChannelLocalId;
    }

    _networksChannelListBlocs[network] = ChannelListBloc(backendService,
        network, networkWithState.channelsWithState, nextChannelIdGenerator);

    Disposable listenForNetworkExit;
    listenForNetworkExit = backendService.listenForNetworkLeave(network, () {
      _networksChannelListBlocs.remove(network).dispose();

      _networks.remove(network);

      // additional list required
      // because we want modify original list during iteration
      var tempListeners = <VoidCallback>[];
      var originalListeners = _leaveListeners[network];
      tempListeners.addAll(originalListeners);
      tempListeners.forEach((listener) => listener());

      // all listeners should dispose itself on leave
      assert(originalListeners.isEmpty);

      _onNetworksChanged(_networks);
      listenForNetworkExit.dispose();
    });
    addDisposable(disposable: listenForNetworkExit);

    _networks.add(network);

    _joinListeners.forEach((listener) => listener(networkWithState));

    _onNetworksChanged(_networks);
  }

  void _onNetworksChanged(List<Network> networks) {
    _networksSubject.add(networks);
  }

  Future<bool> isNetworkWithNameExist(String name) async {
    var found = networks.firstWhere((network) => network.name == name,
        orElse: () => null);

    return found != null;
  }

  Future<int> get _nextNetworkLocalId async => nextNetworkIdGenerator();

  Future<int> get _nextChannelLocalId async => nextChannelIdGenerator();

  final _networksSubject = BehaviorSubject<List<Network>>.seeded([]);

  final List<NetworkListener> _joinListeners = [];
  final Map<Network, List<VoidCallback>> _leaveListeners = {};

  Disposable listenForNetworkJoin(NetworkListener listener) {
    _joinListeners.add(listener);
    return CustomDisposable(
      () {
        _joinListeners.remove(listener);
      },
    );
  }

  Disposable listenForNetworkLeave(
    Network network,
    VoidCallback listener,
  ) {
    if (!_leaveListeners.containsKey(network)) {
      _leaveListeners[network] = [];
    }
    _leaveListeners[network].add(listener);
    return CustomDisposable(() {
      _leaveListeners[network].remove(listener);
    });
  }

  Stream<UnmodifiableListView<Network>> get networksStream =>
      _networksSubject.stream.map((networks) => UnmodifiableListView(networks));

  UnmodifiableListView<Network> get networks => UnmodifiableListView(_networks);

  List<Network> get _networks => _networksSubject.value;

  Stream<int> get networksCountStream => networksStream.map((networks) {
        if (networks != null) {
          return 0;
        } else {
          return networks?.length;
        }
      });

  bool get isNetworksEmpty => _networks.isEmpty;

  Stream<bool> get isNetworksEmptyStream => networksStream.map((networks) {
        if (networks != null) {
          return true;
        } else {
          return networks.isEmpty;
        }
      });

  Future<List<Channel>> get allNetworksChannels async {
    var allChannels = <Channel>[];
    networks.forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  Future<RequestResult<NetworkWithState>> joinNetwork(
          NetworkPreferences preferences,
          {bool waitForResult = false}) async =>
      await backendService.joinNetwork(preferences,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> leaveNetwork(Network network,
          {bool waitForResult = false}) async =>
      await backendService.leaveNetwork(network, waitForResult: waitForResult);

  Network findNetworkWithChannel(Channel channel) =>
      networks.firstWhere((network) => network.channels.contains(channel));
}
