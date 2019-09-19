import 'dart:async';
import 'dart:math';

import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';

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

  Future init() async {}
}

class ChatPreferencesSaverBloc extends ChatPreferencesBloc {
  final ChatNetworksListBloc chatBloc;

  StreamSubscription<List<Network>> networksSubscription;

  ChatPreferencesSaverBloc(PreferencesService preferencesService, this.chatBloc)
      : super(preferencesService) {
    networksSubscription = chatBloc.networksStream.listen((networks) async {
      var newNetworksSettings = networks.map((network) {
        var connectionPreferences = network.connectionPreferences;
        var channels = <IRCNetworkChannelPreferences>[];

        assert(connectionPreferences.localId != null);
        network.channels
            .where((channel) => _isNeedSave(channel))
            .map((channel) {
          assert(channel.channelPreferences.localId != null);
          return channel.channelPreferences;
        });
        return IRCNetworkPreferences(connectionPreferences, channels);
      }).toList();
      var newPreferences = ChatPreferences(newNetworksSettings);

      setValue(newPreferences);
    });
  }

  @override
  void dispose() {
    super.dispose();
    networksSubscription.cancel();
  }
}

_isNeedSave(NetworkChannel channel) => channel.type == IRCNetworkChannelType.CHANNEL;

ChatPreferences _jsonConverter(Map<String, dynamic> json) =>
    ChatPreferences.fromJson(json);
