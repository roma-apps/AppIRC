import 'dart:math';

import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';

var _emptyPreferences = ChatPreferences([]);

ChatPreferences _jsonConverter(Map<String, dynamic> json) =>
    ChatPreferences.fromJson(json);

class ChatPreferencesBloc extends ObjectLocalPreferenceBloc<ChatPreferences> {
  int _maxNetworkLocalId;
  int _maxChannelLocalId;

  int getNextNetworkLocalId() {
    if (_maxNetworkLocalId == null) {
      var preferences = value ?? _emptyPreferences;
      var localIds = preferences.networks.map(
        (network) => network.localId,
      );
      _maxNetworkLocalId = 0;
      localIds.forEach(
        (localId) => _maxNetworkLocalId = max(
          _maxNetworkLocalId,
          localId,
        ),
      );
    }
    return ++_maxNetworkLocalId;
  }

  int getNextChannelLocalId() {
    if (_maxChannelLocalId == null) {
      var preferences = value ?? _emptyPreferences;
      var localIds = <int>[];
      preferences.networks.forEach((network) =>
          network.channels.forEach((channel) => localIds.add(channel.localId)));
      _maxChannelLocalId = 0;
      localIds.forEach(
          (localId) => _maxChannelLocalId = max(_maxChannelLocalId, localId));
    }
    return ++_maxChannelLocalId;
  }

  ChatPreferencesBloc(ILocalPreferencesService preferencesService)
      : super(preferencesService, "chat.preferences", 1, _jsonConverter);
}
