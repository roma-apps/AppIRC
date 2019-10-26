import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChatNetworkChannelsBlocsBloc extends ChatNetworkChannelsListListenerBloc {

  static ChatNetworkChannelsBlocsBloc of(BuildContext context) {
    return Provider.of<ChatNetworkChannelsBlocsBloc>(context);
  }

  Map<NetworkChannel, NetworkChannelBloc> _blocs = Map();
  final ChatBackendService _backendService;
  final ChatNetworkChannelsStateBloc _channelsStatesBloc;

  ChatNetworkChannelsBlocsBloc(this._backendService,
      ChatNetworksListBloc networksListBloc, this._channelsStatesBloc)
      : super(networksListBloc) {
    addDisposable(disposable: CustomDisposable(() {
      _blocs.values.forEach((bloc) => disposeChannelBloc(bloc));
      _blocs.clear();
    }));
  }

  void disposeChannelBloc(NetworkChannelBloc bloc) => bloc.dispose();


  NetworkChannelBloc getNetworkChannelBloc(NetworkChannel channel) =>
      _blocs[channel];

  @override
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState) {
    _blocs[channelWithState.channel] = NetworkChannelBloc(
        _backendService, network, channelWithState, _channelsStatesBloc);
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    disposeChannelBloc(_blocs.remove(channel));
  }
}
