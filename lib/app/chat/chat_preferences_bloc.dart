import 'dart:math';

import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';

var _emptyPreferences = ChatPreferences([]);

ChatPreferences _jsonConverter(Map<String, dynamic> json) =>
    ChatPreferences.fromJson(json);

class ChatPreferencesBloc extends JsonPreferencesBloc<ChatPreferences> {
  int _maxNetworkLocalId;
  int _maxNetworkChannelLocalId;

  int getNextNetworkLocalId() {
    if (_maxNetworkLocalId == null) {
      var preferences = getValue(defaultValue: _emptyPreferences);
      var localIds = preferences.networks.map((network) => network.localId);
      _maxNetworkLocalId = 0;
      localIds.forEach(
          (localId) => _maxNetworkLocalId = max(_maxNetworkLocalId, localId));
    }
    return ++_maxNetworkLocalId;
  }

  int getNextNetworkChannelLocalId() {
    if (_maxNetworkChannelLocalId == null) {
      var preferences = getValue(defaultValue: _emptyPreferences);
      var localIds = <int>[];
      preferences.networks.forEach((network) =>
          network.channels.forEach((channel) => localIds.add(channel.localId)));
      _maxNetworkChannelLocalId = 0;
      localIds.forEach((localId) =>
          _maxNetworkChannelLocalId = max(_maxNetworkChannelLocalId, localId));
    }
    return ++_maxNetworkChannelLocalId;
  }

  ChatPreferencesBloc(PreferencesService preferencesService)
      : super(preferencesService, "chat.preferences", 1, _jsonConverter);
}
