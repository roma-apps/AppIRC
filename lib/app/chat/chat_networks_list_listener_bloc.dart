import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';

abstract class ChatNetworksListListenerBloc extends Providable {
  final ChatNetworksListBloc networksListBloc;

  ChatNetworksListListenerBloc(this.networksListBloc) {
    addDisposable(
        disposable: networksListBloc.listenForNetworkJoin((networkWithState) {
          var network = networkWithState.network;

          addDisposable(
              disposable: networksListBloc.listenForNetworkLeave(network, () {
                onNetworkLeaved(network);
              }));

          onNetworkJoined(networkWithState);
        }));
  }

  @mustCallSuper
  @protected
  void onNetworkJoined(NetworkWithState networkWithState);

  @mustCallSuper
  @protected
  void onNetworkLeaved(Network network);

  ChatNetworkChannelsListBloc getChatNetworkChannelsListBloc(Network network) {
    var chatNetworkChannelsListBloc = networksListBloc
        .getChatNetworkChannelsListBloc(network);
    return chatNetworkChannelsListBloc;
  }
}
