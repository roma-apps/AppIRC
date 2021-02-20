import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';

abstract class PreferencesBloc<T> extends Providable {
  final PreferencesService _preferencesService;
  final String key;

  PreferencesBloc(this._preferencesService, this.key);

  bool get isSavedPreferenceExist => _preferencesService.isKeyExist(key);

  Future<bool> clearValue() => _preferencesService.clearValue(key);

  T getValue({@required T defaultValue});

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

  @override
  Future<bool> setValue(T newValue) => _preferencesService.setJsonPreferences(
        key,
        newValue,
      );

  @override
  Stream<T> valueStream({@required T defaultValue}) =>
      _preferencesService.getJsonPreferencesStream(
        key,
        jsonConverter,
        defaultValue: defaultValue,
      );

  @override
  T getValue({@required T defaultValue}) =>
      _preferencesService.getJsonPreferences(
        key,
        jsonConverter,
        defaultValue: defaultValue,
      );
}

abstract class SimplePreferencesBloc<T> extends PreferencesBloc<T> {
  SimplePreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);
}

class IntPreferencesBloc extends SimplePreferencesBloc<int> {
  IntPreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);

  @override
  Future<bool> setValue(int newValue) async =>
      await _preferencesService.setIntPreferenceValue(key, newValue);

  @override
  Stream<int> valueStream({@required int defaultValue}) => _preferencesService
      .getIntPreferenceStream(key, defaultValue: defaultValue)
      .distinct();

  @override
  int getValue({@required int defaultValue}) =>
      _preferencesService.getIntPreference(
        key,
        defaultValue: defaultValue,
      );
}

class BoolPreferencesBloc extends SimplePreferencesBloc<bool> {
  BoolPreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);

  @override
  Future<bool> setValue(bool newValue) async =>
      await _preferencesService.setBoolPreferenceValue(key, newValue);

  @override
  Stream<bool> valueStream({@required bool defaultValue}) => _preferencesService
      .getBoolPreferenceStream(key, defaultValue: defaultValue)
      .distinct();

  @override
  bool getValue({@required bool defaultValue}) =>
      _preferencesService.getBoolPreference(
        key,
        defaultValue: defaultValue,
      );
}

class StringPreferencesBloc extends SimplePreferencesBloc<String> {
  StringPreferencesBloc(PreferencesService preferencesService, String key)
      : super(preferencesService, key);

  @override
  Future<bool> setValue(String newValue) async =>
      await _preferencesService.setStringValue(key, newValue);

  @override
  Stream<String> valueStream({@required String defaultValue}) =>
      _preferencesService
          .getStringPreferenceStream(key, defaultValue: defaultValue)
          .distinct();

  @override
  String getValue({@required String defaultValue}) =>
      _preferencesService.getStringPreference(
        key,
        defaultValue: defaultValue,
      );
}
