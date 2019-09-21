import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworksStateBloc extends Providable {
  final ChatOutputBackendService backendService;
  final ChatNetworksListBloc networksListBloc;

  final Map<String, BehaviorSubject<NetworkState>> _states = Map();

  ChatNetworksStateBloc(this.backendService, this.networksListBloc) {
    addDisposable(streamSubscription:
        networksListBloc.lastJoinedNetworkStream.listen((networkWithState) {
      var network = networkWithState.network;

      _states[_calculateNetworkKey(network)] =
          BehaviorSubject<NetworkState>(seedValue: NetworkState.empty);
      addDisposable(
          disposable: backendService.listenForNetworkState(
              network, () => _states[_calculateNetworkKey(network)].value, (state) {
        _states[_calculateNetworkKey(network)].add(state);
      }));

      addDisposable(
          disposable: backendService.listenForNetworkExit(network, () {
        _states.remove(_calculateNetworkKey(network)).close();
      }));
    }));
  }

  Stream<NetworkState> getNetworkStateStream(Network network) =>
      _states[_calculateNetworkKey(network)].stream;

  NetworkState getNetworkState(Network network) =>
      _states[_calculateNetworkKey(network)].value;

  String _calculateNetworkKey(Network network) => network.remoteId;
}
