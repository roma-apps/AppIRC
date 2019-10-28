import 'dart:async';

import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _preferenceKeyPrefix = "chat.network";

class NetworkExpandStateBloc extends Providable {
  BoolPreferencesBloc _preferenceBloc;

  Stream<bool> get expandedStream =>
      _preferenceBloc.valueStream(defaultValue: true);
  bool get expanded => _preferenceBloc.getValue(defaultValue: true);

  NetworkExpandStateBloc(
      PreferencesService preferencesService, Network network) {
    var networkLocalId = network.localId;
    _preferenceBloc = BoolPreferencesBloc(
        preferencesService, "$_preferenceKeyPrefix.$networkLocalId");
    addDisposable(disposable: _preferenceBloc);
  }

  void expand() {
    _preferenceBloc.setValue(true);
  }

  void collapse() {
    _preferenceBloc.setValue(false);
  }


  void dispose() {

    super.dispose();
    _preferenceBloc.dispose();
  }
}
