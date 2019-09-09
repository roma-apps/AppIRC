import 'package:flutter_appirc/blocs/preferences_bloc.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/preferences_service.dart';

const _preferencesStorageKey = "lounge_connection";

LoungePreferences createDefaultLoungePreferences() =>
//    LoungePreferences(host: "https://irc.pleroma.social/");
//    LoungePreferences(host: "https://demo.lounge.chat/");
//LoungePreferences(host: "http://192.168.0.103:9000/");
    LoungePreferences(host: "http://192.168.1.103:9000/");

LoungePreferences _jsonConverter(Map<String, dynamic> json) =>
    LoungePreferences.fromJson(json);

class LoungePreferencesBloc extends PreferencesBloc<LoungePreferences> {
  LoungePreferencesBloc(PreferencesService preferencesService,
      {DefaultValueGenerator<LoungePreferences> defaultValueGenerator =
          createDefaultLoungePreferences})
      : super(preferencesService, _preferencesStorageKey, _jsonConverter,
            defaultValueGenerator);
}
