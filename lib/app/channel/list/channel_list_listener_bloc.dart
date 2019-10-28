import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_listener_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';

abstract class ChannelListListenerBloc
    extends NetworkListListenerBloc {
  ChannelListListenerBloc(NetworkListBloc networksListBloc)
      : super(networksListBloc);

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;
    ChannelListBloc chatChannelsListBloc =
        getChannelListBloc(network);

    networkWithState.channelsWithState.forEach((channelWithState) {
      onChannelJoined(network, channelWithState);
      var channel = channelWithState.channel;
      addDisposable(
          disposable: _subscribeForChannelLeave(
              chatChannelsListBloc, network, channel));
    });

    var channelJoinListener = chatChannelsListBloc
        .listenForChannelJoin(((channelWithState) {
      var channel = channelWithState.channel;

      addDisposable(
          disposable: _subscribeForChannelLeave(
              chatChannelsListBloc, network, channel));

      onChannelJoined(network, channelWithState);
    }));

    addDisposable(disposable: channelJoinListener);
  }

  @override
  void onNetworkLeaved(Network network) {
    network.channels.forEach((channel) => onChannelLeaved(network, channel));
  }

  Disposable _subscribeForChannelLeave(
      ChannelListBloc chatChannelsListBloc,
      Network network,
      Channel channel) {
    Disposable leaveListener;
    leaveListener =
        chatChannelsListBloc.listenForChannelLeave(channel, () {
      onChannelLeaved(network, channel);
      leaveListener.dispose();
    });
    return leaveListener;
  }

  @mustCallSuper
  @protected
  void onChannelLeaved(Network network, Channel channel);

  @mustCallSuper
  @protected
  void onChannelJoined(
      Network network, ChannelWithState channelWithState);
}
