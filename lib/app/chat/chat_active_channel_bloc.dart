import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = MyLogger(logTag: "ChatActiveChannelBloc", enabled: true);

class ChatActiveChannelBloc extends ChatNetworkChannelsListListenerBloc {
  final ChatInputBackendService _backendService;
  final ChatNetworksListBloc _networksListBloc;
  final ChatInitBloc _chatInitBloc;
  IntPreferencesBloc _preferenceBloc;

  NetworkChannel get activeChannel => _activeChannelController.value;

  // ignore: close_sinks
  final BehaviorSubject<NetworkChannel> _activeChannelController =
  new BehaviorSubject();

  Stream<NetworkChannel> get activeChannelStream =>
      _activeChannelController.stream;

  ChatActiveChannelBloc(this._backendService, this._chatInitBloc, this._networksListBloc,
      PreferencesService preferencesService) :super(_networksListBloc) {
    _preferenceBloc = createActiveChannelPreferenceBloc(preferencesService);

    _logger.i(() => "start creating");

    addDisposable(disposable: _preferenceBloc);

    addDisposable(subject: _activeChannelController);

    _logger.i(() => "stop creating");
  }

  void tryRestoreActiveChannel() async {
    if(_chatInitBloc.state != ChatInitState.FINISHED) {
      return;
    }

    if (activeChannel != null) {
      return;
    }



    await tryRestoreFromLocalPreferences();
  }

  Future tryRestoreFromLocalPreferences() async {
    var allChannels = await _networksListBloc.allNetworksChannels;

    if (allChannels != null && allChannels.isNotEmpty) {

      var savedLocalId =
      _preferenceBloc.getValue(defaultValue: allChannels.first.localId);
      if (savedLocalId != null) {
        var filtered =
        allChannels.where((channel) => channel.localId == savedLocalId);

        var foundActiveChannel;
        if (filtered.isNotEmpty) {
          foundActiveChannel = filtered.first;
        }

        if (foundActiveChannel == null && allChannels.isNotEmpty) {
          foundActiveChannel = allChannels.first;
        }

        if (foundActiveChannel != null) {
          changeActiveChanel(foundActiveChannel);
        }
      }
    }
  }

  changeActiveChanel(NetworkChannel newActiveChannel) async {
    if(_chatInitBloc.state != ChatInitState.FINISHED) {
      return;
    }

    if (activeChannel == newActiveChannel) {
      return;
    }

    _logger.i(() => "changeActiveChanel $newActiveChannel");
    _preferenceBloc.setValue(newActiveChannel.localId);
    _activeChannelController.sink.add(newActiveChannel);

    Network network =
    _networksListBloc.findNetworkWithChannel(newActiveChannel);
    _backendService.onOpenNetworkChannel(network, newActiveChannel);
  }

  _onActiveChannelLeaved() async {
    var allChannels = await _networksListBloc.allNetworksChannels;

    if (allChannels.length > 0) {
      changeActiveChanel(allChannels.first);
    }
  }


  IntPreferencesBloc createActiveChannelPreferenceBloc(
      PreferencesService preferencesService) =>
      IntPreferencesBloc(preferencesService, _preferenceKey);

  @override
  void onChannelJoined(Network network, NetworkChannelWithState channelWithState) {
    var channel = channelWithState.channel;
    changeActiveChanel(channel);
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    if (activeChannel == channel) {
      _onActiveChannelLeaved();
    }

  }

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {


    if(activeChannel == null) {
      tryRestoreActiveChannel();
    } else {
      changeActiveChanel(networkWithState.network.lobbyChannel);
    }

    super.onNetworkJoined(networkWithState);
  }
}
