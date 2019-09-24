import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = MyLogger(logTag: "IRCChatActiveChannelBloc", enabled: true);

class ChatActiveChannelBloc extends Providable {
  final ChatInputBackendService backendService;
  final ChatNetworksListBloc _networksListBloc;
  IntPreferencesBloc _preferenceBloc;

  NetworkChannel get activeChannel => _activeChannelController.value;

  // ignore: close_sinks
  final BehaviorSubject<NetworkChannel> _activeChannelController =
      new BehaviorSubject();

  Stream<NetworkChannel> get activeChannelStream =>
      _activeChannelController.stream;

  ChatActiveChannelBloc(this.backendService, this._networksListBloc, PreferencesService preferencesService) {

    _preferenceBloc = createActiveChannelPreferenceBloc(preferencesService);

    _logger.i(() => "start creating");

    addDisposable(disposable: _preferenceBloc);

    addDisposable(subject: _activeChannelController);
    addDisposable(
        streamSubscription: _networksListBloc.networksStream
            .listen((newNetworks) async => _onNetworksListChanged()));

    _logger.i(() => "stop creating");
  }

  void _onNetworksListChanged() async {
    if (activeChannel == null) {
      var allChannels = await _networksListBloc.allNetworksChannels;

      if (allChannels != null && allChannels.isNotEmpty) {
        var savedLocalId =  _preferenceBloc.getValue(
            defaultValue: allChannels.first.localId);
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
  }

  changeActiveChanel(NetworkChannel newActiveChannel) async {
    if (activeChannel == newActiveChannel) {
      return;
    }

    _logger.i(() => "changeActiveChanel $newActiveChannel");
    _preferenceBloc.setValue(newActiveChannel.localId);
    _activeChannelController.sink.add(newActiveChannel);
    
    Network network = _networksListBloc.findNetworkWithChannel(newActiveChannel);
    backendService.onOpenNetworkChannel(network, newActiveChannel);
  }
}

IntPreferencesBloc createActiveChannelPreferenceBloc(
        PreferencesService preferencesService) =>
    IntPreferencesBloc(preferencesService, _preferenceKey);
