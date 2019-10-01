import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChatNetworkChannelsBlocsBloc extends ChatNetworkChannelsListListenerBloc {

  static ChatNetworkChannelsBlocsBloc of(BuildContext context) {
    return Provider.of<ChatNetworkChannelsBlocsBloc>(context);
  }

  Map<NetworkChannel, NetworkChannelBloc> _blocs = Map();
  final ChatInputBackendService _backendService;
  final ChatNetworkChannelsStateBloc _channelsStatesBloc;

  ChatNetworkChannelsBlocsBloc(this._backendService,
      ChatNetworksListBloc networksListBloc, this._channelsStatesBloc)
      : super(networksListBloc) {
    addDisposable(disposable: CustomDisposable(() {
      _blocs.values.forEach((bloc) => bloc.dispose());
      _blocs.clear();
    }));
  }

  NetworkChannelBloc getNetworkChannelBloc(NetworkChannel channel) =>
      _blocs[channel];

  @override
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState) {
    var channel = channelWithState.channel;
    _blocs[channel] = NetworkChannelBloc(
        _backendService, network, channel, _channelsStatesBloc);
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    _blocs.remove(channel).dispose();
  }
}
