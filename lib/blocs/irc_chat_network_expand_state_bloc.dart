import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/blocs/preferences_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
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
