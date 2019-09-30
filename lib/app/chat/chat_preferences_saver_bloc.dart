import 'dart:math';

import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';

var _logger = MyLogger(logTag: "ChatPreferencesSaverBloc", enabled: true);

class ChatPreferencesSaverBloc extends ChatNetworkChannelsListListenerBloc {
  final ChatPreferences _currentPreferences = ChatPreferences([]);
  final ChatPreferencesBloc chatPreferencesBloc;
  final ChatInitBloc initBloc;

  ChatPreferencesSaverBloc(
      ChatNetworksListBloc networksListBloc, this.chatPreferencesBloc, this.initBloc)
      : super(networksListBloc);


  @override
  void onNetworkJoined(NetworkWithState networkWithState) {

    var network = networkWithState.network;

    _currentPreferences.networks.add(ChatNetworkPreferences(
        network.connectionPreferences, []));

    _onPreferencesChanged();

    super.onNetworkJoined(networkWithState);
  }

  @override
  void onNetworkLeaved(Network network) {
    super.onNetworkLeaved(network);

    _currentPreferences.networks.remove(findPreferencesForNetwork(network));

    _onPreferencesChanged();



  }

    @override
  void onChannelJoined(Network network, NetworkChannelWithState channelWithState) {
      var channel = channelWithState.channel;
      var networkPreference = findPreferencesForNetwork(network);

      if (_isNeedSaveChannel(channel)) {
        var channelPreferences = channel.channelPreferences;
        networkPreference.channels.add(channelPreferences);
        _onPreferencesChanged();
      }
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    findPreferencesForNetwork(network)
        .channels
        .remove(channel.channelPreferences);
    _onPreferencesChanged();
  }

  void _onPreferencesChanged() {

    var isInitFinished = initBloc.isInitFinished;
    _logger.d(() => "onPreferencesChanged isInitFinished $isInitFinished");

    if(isInitFinished) {
      _logger.d(() => "save new chat preferences $_currentPreferences");
      chatPreferencesBloc.setValue(_currentPreferences);
    }

  }

  ChatNetworkPreferences findPreferencesForNetwork(Network network) {
    return _currentPreferences.networks.firstWhere((networkPreference) {
      return networkPreference.networkConnectionPreferences.name ==
          network.name;
    }, orElse: () => null);
  }


}

_isNeedSaveChannel(NetworkChannel channel) =>
    channel.type == NetworkChannelType.CHANNEL;

