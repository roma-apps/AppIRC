import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

const _preferencesStorageKey = "lounge.connection";



LoungeConnectionPreferences _jsonConverter(Map<String, dynamic> json) =>
    LoungeConnectionPreferences.fromJson(json);

class LoungePreferencesBloc extends JsonPreferencesBloc<LoungeConnectionPreferences> {
  LoungePreferencesBloc(PreferencesService preferencesService)
      : super(preferencesService, _preferencesStorageKey, 1, _jsonConverter);
}
