import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';

abstract class PreferencesBloc<T> extends Providable {
  final PreferencesService _preferencesService;
  final String key;

  PreferencesBloc(this._preferencesService, this.key);

  Future<bool> get isSavedPreferenceExist async =>
      await _preferencesService.isKeyExist(key);

  Future<bool> clearValue() => _preferencesService.clearValue(key);

  Future<T> getValue({@required T defaultValue});

  Future<bool> setValue(T newValue);

  Stream<T> valueStream({@required T defaultValue});


}

class JsonPreferencesBloc<T extends JsonPreferences>
    extends PreferencesBloc<T> {
  final int schemaVersion;
  final T Function(Map<String, dynamic> jsonData) jsonConverter;

  JsonPreferencesBloc(PreferencesService preferencesService, String key,
      this.schemaVersion, this.jsonConverter)
      : super(preferencesService, "$key.$schemaVersion");

  Future<bool> setValue(T newValue) async =>  await _preferencesService.setJsonPreferences(key, newValue);

  Stream<T> valueStream({@required T defaultValue}) => _preferencesService
      .getJsonPreferencesStream(key, jsonConverter, defaultValue: defaultValue);

  Future<T> getValue({@required T defaultValue}) async =>
      await _preferencesService
          .getJsonPreferences(key, jsonConverter, defaultValue: defaultValue);
}

abstract class SimplePreferencesBloc<T> extends PreferencesBloc<T> {
  SimplePreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);
}

class IntPreferencesBloc extends SimplePreferencesBloc<int> {
  IntPreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);

  Future<bool> setValue(int newValue) async =>
      await _preferencesService.setIntPreferenceValue(key, newValue);

  Stream<int> valueStream({@required int defaultValue}) => _preferencesService
      .getIntPreferenceStream(key, defaultValue: defaultValue);


  Future<int> getValue({@required int defaultValue}) async =>
      _preferencesService
          .getIntPreference(key, defaultValue: defaultValue);

}

class BoolPreferencesBloc extends SimplePreferencesBloc<bool> {
  BoolPreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);

  Future<bool> setValue(bool newValue) async =>
      await _preferencesService.setBoolPreferenceValue(key, newValue);

  Stream<bool> valueStream({@required bool defaultValue}) => _preferencesService
      .getBoolPreferenceStream(key, defaultValue: defaultValue);

  Future<bool> getValue({@required bool defaultValue}) async =>
      _preferencesService
          .getBoolPreference(key, defaultValue: defaultValue);
}
