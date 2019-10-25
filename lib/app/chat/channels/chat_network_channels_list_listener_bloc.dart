import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_list_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_listener_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';

abstract class ChatNetworkChannelsListListenerBloc
    extends ChatNetworksListListenerBloc {
  ChatNetworkChannelsListListenerBloc(ChatNetworksListBloc networksListBloc)
      : super(networksListBloc);

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;
    ChatNetworkChannelsListBloc chatNetworkChannelsListBloc =
        getChatNetworkChannelsListBloc(network);

    networkWithState.channelsWithState.forEach((channelWithState) {
      onChannelJoined(network, channelWithState);
      var channel = channelWithState.channel;
      addDisposable(
          disposable: _subscribeForChannelLeave(
              chatNetworkChannelsListBloc, network, channel));
    });

    var channelJoinListener = chatNetworkChannelsListBloc
        .listenForNetworkChannelJoin(((channelWithState) {
      var channel = channelWithState.channel;

      addDisposable(
          disposable: _subscribeForChannelLeave(
              chatNetworkChannelsListBloc, network, channel));

      onChannelJoined(network, channelWithState);
    }));

    addDisposable(disposable: channelJoinListener);
  }

  @override
  void onNetworkLeaved(Network network) {
    network.channels.forEach((channel) => onChannelLeaved(network, channel));
  }

  Disposable _subscribeForChannelLeave(
      ChatNetworkChannelsListBloc chatNetworkChannelsListBloc,
      Network network,
      NetworkChannel channel) {
    Disposable leaveListener;
    leaveListener =
        chatNetworkChannelsListBloc.listenForNetworkChannelLeave(channel, () {
      onChannelLeaved(network, channel);
      leaveListener.dispose();
    });
    return leaveListener;
  }



  @mustCallSuper
  @protected
  void onChannelLeaved(Network network, NetworkChannel channel);

  @mustCallSuper
  @protected
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState);
}
