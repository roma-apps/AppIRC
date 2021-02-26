import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_listener_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("network_states_bloc.dart");

class NetworkStatesBloc extends NetworkListListenerBloc {
  final ChatBackendService backendService;
  final Map<String, BehaviorSubject<NetworkState>> _states = {};

  Stream<NetworkState> getNetworkStateStream(Network network) =>
      _states[_calculateNetworkKey(network)].stream;

  NetworkState getNetworkState(Network network) =>
      _states[_calculateNetworkKey(network)].value;

  String _calculateNetworkKey(Network network) => network.remoteId;

  NetworkStatesBloc({
    @required this.backendService,
    @required NetworkListBloc networkListBloc,
  }) : super(networkListBloc: networkListBloc);

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;

    _states[_calculateNetworkKey(network)] =
        BehaviorSubject<NetworkState>.seeded(networkWithState.state);

    addDisposable(
      disposable: backendService.listenForNetworkState(
        network: network,
        currentStateExtractor: () =>
            _states[_calculateNetworkKey(network)].value,
        listener: (state) {
          _logger.fine(() => "onNewNetworkState $state");

          _states[_calculateNetworkKey(network)].add(state);
        },
      ),
    );
  }

  @override
  void onNetworkLeaved(Network network) {
    _states.remove(_calculateNetworkKey(network)).close();
  }
}
