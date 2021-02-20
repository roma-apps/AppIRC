import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_listener_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/app/network/state/network_states_bloc.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkBlocsBloc extends NetworkListListenerBloc {
  static NetworkBlocsBloc of(BuildContext context) {
    return Provider.of<NetworkBlocsBloc>(context);
  }

  final Map<Network, NetworkBloc> _blocs = {};
  final ChatBackendService _backendService;
  final NetworkStatesBloc _networkStatesBloc;
  final ChannelStatesBloc _channelsStatesBloc;
  final ChatActiveChannelBloc _activeChannelBloc;

  NetworkBlocsBloc(
      this._backendService,
      NetworkListBloc networksListBloc,
      this._networkStatesBloc,
      this._channelsStatesBloc,
      this._activeChannelBloc)
      : super(networksListBloc) {
    addDisposable(disposable: CustomDisposable(() {
      _blocs.values.forEach((bloc) => bloc.dispose());
      _blocs.clear();
    }));
  }

  NetworkBloc getNetworkBloc(Network network) => _blocs[network];

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;
    _blocs[network] = NetworkBloc(_backendService, network, _networkStatesBloc,
        _channelsStatesBloc, _activeChannelBloc);
  }

  @override
  void onNetworkLeaved(Network network) {
    _blocs.remove(network).dispose();
  }
}
