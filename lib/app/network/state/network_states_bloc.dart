import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_listener_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "network_states_bloc.dart", enabled: true);

class NetworkStatesBloc extends NetworkListListenerBloc {
  final ChatBackendService _backendService;
  final Map<String, BehaviorSubject<NetworkState>> _states = Map();

  Stream<NetworkState> getNetworkStateStream(Network network) =>
      _states[_calculateNetworkKey(network)].stream;

  NetworkState getNetworkState(Network network) =>
      _states[_calculateNetworkKey(network)].value;

  String _calculateNetworkKey(Network network) => network.remoteId;

  NetworkStatesBloc(
      this._backendService, NetworkListBloc networksListBloc)
      : super(networksListBloc);

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;

    _states[_calculateNetworkKey(network)] =
        BehaviorSubject<NetworkState>(seedValue: networkWithState.state);

    addDisposable(
        disposable: _backendService.listenForNetworkState(
            network, () => _states[_calculateNetworkKey(network)].value,
            (state) {
      _logger.d(() => "onNewNetworkState $state");

      _states[_calculateNetworkKey(network)].add(state);
    }));
  }

  @override
  void onNetworkLeaved(Network network) {
    _states.remove(_calculateNetworkKey(network)).close();
  }
}
