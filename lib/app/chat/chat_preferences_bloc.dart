import 'dart:async';
import 'dart:math';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';

var _logger = MyLogger(logTag: "ChatPreferencesBloc", enabled: true);

var _emptyPreferences = ChatPreferences([]);

abstract class ChatPreferencesBloc
    extends JsonPreferencesBloc<ChatPreferences> {
  ChatPreferencesBloc(PreferencesService preferencesService)
      : super(preferencesService, "chat.preferences", 1, _jsonConverter);
}

class ChatPreferencesLoaderBloc extends ChatPreferencesBloc {
  int _maxNetworkLocalId;
  int _maxNetworkChannelLocalId;

  ChatPreferencesLoaderBloc(PreferencesService preferencesService)
      : super(preferencesService);

  Future<int> getNextNetworkLocalId() async {
    if (_maxNetworkLocalId == null) {
      var preferences = (await getValue(defaultValue: _emptyPreferences));
      var localIds = preferences.networks.map((network) => network.localId);
      _maxNetworkLocalId = 0;
      localIds.forEach(
          (localId) => _maxNetworkLocalId = max(_maxNetworkLocalId, localId));
    }
    return ++_maxNetworkLocalId;
  }

  Future<int> getNextNetworkChannelLocalId() async {
    if (_maxNetworkChannelLocalId == null) {
      var preferences = (await getValue(defaultValue: _emptyPreferences));
      var localIds = <int>[];
      preferences.networks.forEach((network) =>
          network.channels.forEach((channel) => localIds.add(channel.localId)));
      _maxNetworkChannelLocalId = 0;
      localIds.forEach((localId) =>
          _maxNetworkChannelLocalId = max(_maxNetworkChannelLocalId, localId));
    }
    return ++_maxNetworkChannelLocalId;
  }
}

class ChatPreferencesSaverBloc extends ChatPreferencesBloc {
  final ChatOutputBackendService backendService;
  final ChatNetworksListBloc networkListBloc;
  final ChatInitBloc initBloc;
  ChatPreferences _currentPreferences;

  ChatPreferencesSaverBloc(this.backendService,
      PreferencesService preferencesService, this.networkListBloc, this.initBloc)
      : super(preferencesService) {
    addDisposable(streamSubscription: initBloc.stateStream.listen((newState) {
      _logger.d(() => "onState $newState");

      if (newState == ChatInitState.FINISHED) {
        var networks = networkListBloc.networks;
        var newNetworksSettings = networks.map((network) {
          var connectionPreferences = network.connectionPreferences;

          assert(connectionPreferences.localId != null);
          var channels = network.channels
              .where((channel) => _isNeedSave(channel))
              .map((channel) {
            assert(channel.channelPreferences.localId != null);
            return channel.channelPreferences;
          }).toList();
          return ChatNetworkPreferences(connectionPreferences, channels);
        }).toList();
        var newPreferences = ChatPreferences(newNetworksSettings);

        onNewPreferences(newPreferences);

        for (var network in networks) {
          onNetworkEntered(network, true);
        }

        backendService.listenForNetworkEnter((newNetworkWithState) {
          onNetworkEntered(newNetworkWithState.network, false);
        });
      }
    }));
  }

  void onNewPreferences(ChatPreferences newPreferences) {
    _currentPreferences = newPreferences;
    _logger.d(() => "save new chat preferences $newPreferences");
    setValue(newPreferences);
  }

  ChatNetworkPreferences findPreferencesForNetwork(Network network) {
    return _currentPreferences.networks.firstWhere((networkPreference) {
      return networkPreference.networkConnectionPreferences.name ==
          network.name;
    }, orElse: () => null);
  }

  void onNetworkEntered(Network network, bool isInitFromStart) {
    if (!isInitFromStart) {
      _currentPreferences.networks.add(ChatNetworkPreferences(
          network.connectionPreferences,
          network.channels
              .where((channel) => _isNeedSave(channel))
              .toList()
              .map((channel) => channel.channelPreferences)
              .toList()));
      onNewPreferences(_currentPreferences);
    }

    for (var channel in network.channels) {
      _listenForNetworkChannelLeave(network, channel);
    }

    backendService.listenForNetworkChannelJoin(network, (newChannelWithState) {
      addDisposable(
          disposable: backendService.listenForNetworkChannelJoin(network,
              (newChannelWithState) {
        var channel = newChannelWithState.channel;

        var networkPreference = findPreferencesForNetwork(network);

        if (_isNeedSave(channel)) {
          networkPreference.channels.add(channel.channelPreferences);
        }

        _listenForNetworkChannelLeave(network, channel);
      }));
    });
  }

  void _listenForNetworkChannelLeave(Network network, NetworkChannel channel) {
    Disposable listener;
    listener =
        backendService.listenForNetworkChannelLeave(network, channel, () {
      findPreferencesForNetwork(network)
          .channels
          .remove(channel.channelPreferences);
      onNewPreferences(_currentPreferences);

      listener.dispose();
    });
    addDisposable(disposable: listener);
  }
}

_isNeedSave(NetworkChannel channel) =>
    channel.type == NetworkChannelType.CHANNEL;

ChatPreferences _jsonConverter(Map<String, dynamic> json) =>
    ChatPreferences.fromJson(json);
