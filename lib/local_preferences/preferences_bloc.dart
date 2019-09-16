import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';

typedef T DefaultValueGenerator<T>();

abstract class PreferencesBloc<T> extends AsyncOperationBloc {
  final PreferencesService _preferencesService;
  final String key;

  T getDefaultValue();

  bool get isSavedPreferenceExist =>
      _preferencesService.isPreferencesExist(key);

  deleteValue() => _preferencesService.deletePreferencesValue(key);

  PreferencesBloc(this._preferencesService, this.key);

  T getPreferenceOrDefault();

  T getPreferenceOrValue(T valueExtractor());

  Future<bool> setNewPreferenceValue(T newValue);

  Stream<T> get preferenceStream;
}

class JsonPreferencesBloc<T extends JsonPreferences>
    extends PreferencesBloc<T> {
  final int schemaVersion;
  final T Function(Map<String, dynamic> jsonData) jsonConverter;
  final DefaultValueGenerator<T> defaultValueGenerator;

  T getDefaultValue() => defaultValueGenerator();

  JsonPreferencesBloc(PreferencesService preferencesService, String key, this.schemaVersion,
      this.jsonConverter, this.defaultValueGenerator)
      : super(preferencesService, "$key.$schemaVersion");

  T getPreferenceOrDefault() =>
      _preferencesService.getJsonPreferences(key, jsonConverter,
          defaultValue: defaultValueGenerator());

  T getPreferenceOrValue(T value()) => _preferencesService
      .getJsonPreferences(key, jsonConverter, defaultValue: value());

  setNewPreferenceValue(T newValue) async => doAsyncOperation(
      () async => await _preferencesService.setJsonPreferences(key, newValue));

  Stream<T> get preferenceStream =>
      _preferencesService.getJsonPreferencesStream(key, jsonConverter,
          defaultValue: defaultValueGenerator());
}

abstract class SimplePreferencesBloc<T> extends PreferencesBloc<T> {
  T defaultValue;

  SimplePreferencesBloc(
      PreferencesService preferencesService, String key, this.defaultValue)
      : super(preferencesService, key);

  T getDefaultValue() => defaultValue;
}

class IntPreferencesBloc extends SimplePreferencesBloc<int> {
  IntPreferencesBloc(
      PreferencesService preferencesService, String key, int defaultValue)
      : super(preferencesService, key, defaultValue);

  int getPreferenceOrDefault() =>
      _preferencesService.getIntPreference(key, defaultValue: defaultValue);

  int getPreferenceOrValue(int value()) =>
      _preferencesService.getIntPreference(key, defaultValue: value());

  Future<bool> setNewPreferenceValue(int newValue) async =>
      doAsyncOperation(() async =>
          await _preferencesService.setIntPreferenceValue(key, newValue));

  Stream<int> get preferenceStream => _preferencesService
      .getIntPreferenceStream(key, defaultValue: defaultValue);
}

class BoolPreferencesBloc extends SimplePreferencesBloc<bool> {
  BoolPreferencesBloc(
      PreferencesService preferencesService, String key, bool defaultValue)
      : super(preferencesService, key, defaultValue);

  bool getPreferenceOrDefault() =>
      _preferencesService.getBoolPreference(key, defaultValue: defaultValue);

  bool getPreferenceOrValue(bool value()) =>
      _preferencesService.getBoolPreference(key, defaultValue: value());

  Future<bool> setNewPreferenceValue(bool newValue) async =>
      doAsyncOperation(() async =>
          await _preferencesService.setBoolPreferenceValue(key, newValue));

  Stream<bool> get preferenceStream => _preferencesService
      .getBoolPreferenceStream(key, defaultValue: defaultValue);
}
