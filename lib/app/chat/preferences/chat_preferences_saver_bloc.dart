import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/app/network/state/network_states_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';

var _logger =
    MyLogger(logTag: "chat_preferences_saver_bloc.dart", enabled: true);

class ChatPreferencesSaverBloc extends ChannelListListenerBloc {
  final ChatBackendService _backendService;
  final NetworkStatesBloc _stateBloc;
  ChatPreferences _currentPreferences = ChatPreferences([]);
  final ChatPreferencesBloc chatPreferencesBloc;
  final ChatInitBloc initBloc;

  ChatPreferencesSaverBloc(
      this._backendService,
      this._stateBloc,
      NetworkListBloc networksListBloc,
      this.chatPreferencesBloc,
      this.initBloc)
      : super(networksListBloc);

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;

    _currentPreferences.networks
        .add(NetworkPreferences(network.connectionPreferences, []));

    addDisposable(
        disposable: _backendService.listenForNetworkEdit(network,
            (NetworkPreferences networkPreferences) {
      findPreferencesForNetwork(network).networkConnectionPreferences =
          networkPreferences.networkConnectionPreferences;
      _onPreferencesChanged();
    }));

    addDisposable(
        streamSubscription:
            _stateBloc.getNetworkStateStream(network).listen((state) {
      var newNick = state.nick;
      var oldUserPreferences = findPreferencesForNetwork(network)
          .networkConnectionPreferences
          .userPreferences;

      if (oldUserPreferences.nickname != newNick) {
        oldUserPreferences.nickname = newNick;
        _onPreferencesChanged();
      }
    }));

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
  void onChannelJoined(
      Network network, ChannelWithState channelWithState) {
    _logger.d(() => "onChannelJoined $channelWithState");

    var channel = channelWithState.channel;
    var networkPreference = findPreferencesForNetwork(network);

    if (_isNeedSaveChannel(channel)) {
      var channelPreferences = channel.channelPreferences;
      networkPreference.channels.add(channelPreferences);
      _onPreferencesChanged();
    }
  }

  @override
  void onChannelLeaved(Network network, Channel channel) {
    findPreferencesForNetwork(network)
        .channels
        .remove(channel.channelPreferences);
    _onPreferencesChanged();
  }

  void _onPreferencesChanged() {
    var isInitFinished = initBloc.isInitFinished;
    _logger.d(() => "onPreferencesChanged isInitFinished $isInitFinished");

    if (isInitFinished) {
      _logger.d(() => "save new chat preferences $_currentPreferences");
      chatPreferencesBloc.setValue(_currentPreferences);
    }
  }

  NetworkPreferences findPreferencesForNetwork(Network network) {
    return _currentPreferences.networks.firstWhere((networkPreference) {
      if (network.localId == networkPreference.localId) {
        return true;
      } else {
        // sometimes we don't have local id and name should be unique
        return networkPreference.networkConnectionPreferences.name ==
            network.name;
      }
    }, orElse: () => null);
  }

  reset() {
    _currentPreferences = ChatPreferences.empty;
    _onPreferencesChanged();

  }
}

_isNeedSaveChannel(Channel channel) =>
    channel.type == ChannelType.channel;
