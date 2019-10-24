import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChatNetworksBlocsBloc extends ChatNetworksListListenerBloc {
  static ChatNetworksBlocsBloc of(BuildContext context) {
    return Provider.of<ChatNetworksBlocsBloc>(context);
  }

  Map<Network, NetworkBloc> _blocs = Map();
  final ChatInputBackendService backendService;
  final ChatNetworksStateBloc networkStatesBloc;
  final ChatNetworkChannelsStateBloc channelsStatesBloc;
  final ChatActiveChannelBloc activeChannelBloc;

  ChatNetworksBlocsBloc(
      this.backendService,
      ChatNetworksListBloc networksListBloc,
      this.networkStatesBloc,
      this.channelsStatesBloc,
      this.activeChannelBloc)
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
    _blocs[network] = NetworkBloc(backendService, network, networkStatesBloc,
        channelsStatesBloc, activeChannelBloc);
  }

  @override
  void onNetworkLeaved(Network network) {
    _blocs.remove(network).dispose();
  }
}
