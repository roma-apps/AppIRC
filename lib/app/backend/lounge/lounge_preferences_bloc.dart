import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

const _preferencesStorageKey = "lounge.connection";

LoungePreferences createDefaultLoungePreferences() =>
//    LoungePreferences(host: "https://demo.thelounge.chat/");
//LoungePreferences(host: "https://irc.pleroma.social");
LoungePreferences(host: "http://192.168.0.103:9000/");
//LoungePreferences(host: "http://192.168.1.103:9000/");

LoungePreferences _jsonConverter(Map<String, dynamic> json) =>
    LoungePreferences.fromJson(json);

class LoungePreferencesBloc extends JsonPreferencesBloc<LoungePreferences> {
  LoungePreferencesBloc(PreferencesService preferencesService,
      {DefaultValueGenerator<LoungePreferences> defaultValueGenerator =
          createDefaultLoungePreferences})
      : super(preferencesService, _preferencesStorageKey, 1, _jsonConverter,
            defaultValueGenerator);
}
