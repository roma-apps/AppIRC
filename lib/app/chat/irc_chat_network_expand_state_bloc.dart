import 'dart:async';

import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _preferenceKeyPrefix = "chat.network";
var _logger = MyLogger(logTag: "IRCChatNetworkExpandStateBloc", enabled: true);

class IRCChatNetworkExpandStateBloc extends Providable {
  BoolPreferencesBloc preferenceBloc;

  Stream<bool> get expandedStream => preferenceBloc.valueStream(true);

  IRCChatNetworkExpandStateBloc(
      PreferencesService preferencesService, IRCNetwork network) {
    var networkLocalId = network.localId;
    preferenceBloc = BoolPreferencesBloc(
        preferencesService, "$_preferenceKeyPrefix.$networkLocalId");
  }

  expand() {
    preferenceBloc.setValue(true);
  }

  collapse() {
    preferenceBloc.setValue(false);
  }

  void dispose() {
    preferenceBloc.dispose();
  }
}
