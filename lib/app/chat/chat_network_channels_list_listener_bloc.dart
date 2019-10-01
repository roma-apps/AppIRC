import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_listener_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';

abstract class ChatNetworkChannelsListListenerBloc
    extends ChatNetworksListListenerBloc {
  ChatNetworkChannelsListListenerBloc(ChatNetworksListBloc networksListBloc)
      : super(networksListBloc);

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {

    var network = networkWithState.network;

    networkWithState.channelsWithState.forEach(
        (channelWithState) => onChannelJoined(network, channelWithState));

    ChatNetworkChannelsListBloc chatNetworkChannelsListBloc =
        getChatNetworkChannelsListBloc(network);

    var channelJoinListener = chatNetworkChannelsListBloc
        .listenForNetworkChannelJoin(((channelWithState) {
      var channel = channelWithState.channel;
      Disposable leaveListener;
      leaveListener =
          chatNetworkChannelsListBloc.listenForNetworkChannelLeave(channel, () {
        onChannelLeaved(network, channel);
        leaveListener.dispose();
      });

      onChannelJoined(network, channelWithState);

      addDisposable(disposable: leaveListener);
    }));

    addDisposable(disposable: channelJoinListener);
  }

  @mustCallSuper
  @protected
  void onChannelLeaved(Network network, NetworkChannel channel);

  @mustCallSuper
  @protected
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState);

  @override
  void onNetworkLeaved(Network network) {
    network.channels.forEach((channel) => onChannelLeaved(network, channel));
  }
}
