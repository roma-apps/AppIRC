import 'dart:async';

import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';

var _preferenceKeyPrefix = "chat.network";

class NetworkExpandStateBloc extends DisposableOwner {
  BoolLocalPreferenceBloc _preferenceBloc;

  Stream<bool> get expandedStream => _preferenceBloc.stream;

  bool get expanded => _preferenceBloc.value ?? true;

  NetworkExpandStateBloc(
      ILocalPreferencesService preferencesService, Network network) {
    var networkLocalId = network.localId;
    _preferenceBloc = BoolLocalPreferenceBloc(
      preferencesService,
      "$_preferenceKeyPrefix.$networkLocalId",
    );

    addDisposable(disposable: _preferenceBloc);
  }

  void expand() {
    _preferenceBloc.setValue(true);
  }

  void collapse() {
    _preferenceBloc.setValue(false);
  }
}
