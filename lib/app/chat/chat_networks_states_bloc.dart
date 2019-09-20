import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworksStateBloc extends Providable {
  final ChatOutputBackendService backendService;
  final ChatNetworksListBloc networksListBloc;

  final Map<Network, BehaviorSubject<NetworkState>> _states =
      Map<Network, BehaviorSubject<NetworkState>>();

  ChatNetworksStateBloc(this.backendService, this.networksListBloc) {
    addDisposable(streamSubscription:
    networksListBloc.lastJoinedNetworkStream.listen((network) {
      _states[network] = BehaviorSubject<NetworkState>(seedValue: NetworkState.empty);
      addDisposable(
          disposable: backendService.listenForNetworkState(network,()=> _states[network].value, (state) {
            _states[network].add(state);
          }));

      addDisposable(
          disposable: backendService.listenForNetworkExit(network, () {
            _states.remove(network).close();
          }));
    }));
  }

  Stream<NetworkState> getNetworkStateStream(Network network) =>
      _states[network].stream;

  NetworkState getNetworkState(Network network) =>
      _states[network].value;


}
