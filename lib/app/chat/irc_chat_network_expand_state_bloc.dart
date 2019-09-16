import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/app/networks/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKeyPrefix = "chat.network";
var _logger = MyLogger(logTag: "IRCChatBloc", enabled: true);

class IRCChatNetworkExpandStateBloc extends Providable {
  BoolPreferencesBloc preferenceBloc;

  Stream<bool> get expandedStream => preferenceBloc.preferenceStream;
  IRCChatNetworkExpandStateBloc(
      PreferencesService preferencesService, IRCNetwork network) {
    var networkLocalId = network.localId;
    preferenceBloc = BoolPreferencesBloc(
        preferencesService, "$_preferenceKeyPrefix.$networkLocalId", true);
  }

  expand() {
    preferenceBloc.setNewPreferenceValue(true);
  }

  collapse() {
    preferenceBloc.setNewPreferenceValue(false);
  }

  void dispose() {
    preferenceBloc.dispose();
  }


}
