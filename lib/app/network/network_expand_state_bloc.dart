import 'dart:async';

import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _preferenceKeyPrefix = "chat.network";

class ChatNetworkExpandStateBloc extends Providable {
  BoolPreferencesBloc preferenceBloc;

  Stream<bool> get expandedStream => preferenceBloc.valueStream(defaultValue: true);
  bool get expanded => preferenceBloc.getValue(defaultValue: true);

  ChatNetworkExpandStateBloc(
      PreferencesService preferencesService, Network network) {
    var networkLocalId = network.localId;
    preferenceBloc = BoolPreferencesBloc(
        preferencesService, "$_preferenceKeyPrefix.$networkLocalId");
    addDisposable(disposable: preferenceBloc);
  }

  expand() {
    preferenceBloc.setValue(true);
  }

  collapse() {
    preferenceBloc.setValue(false);
  }


}
