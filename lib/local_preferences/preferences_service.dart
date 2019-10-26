import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

var _logger = MyLogger(logTag: "preferences_service.dart", enabled: true);

class PreferencesService extends Providable {
  StreamingSharedPreferences _preferences;

  Future init() async {
    _preferences = await StreamingSharedPreferences.instance;
  }

  void clear() {
    _preferences.clear();
  }

  bool isKeyExist(String key)  {
    Set<String> keys = _preferences.getKeys().getValue();
    _logger.d(() => "isKeyExist $keys");
    var contains = keys.contains(key);
    _logger.d(() => "isKeyExist $key => $contains");
    return contains;
  }

  Future<bool> clearValue(String key) async => _preferences.remove(key);

  Preference<String> getStringPreferenceStream(String key,
          {@required String defaultValue}) =>
      _preferences.getString(key, defaultValue: defaultValue);

  Future<bool> setStringValue(String key, String value) async =>
      await _preferences.setString(key, value);

  Preference<int> getIntPreferenceStream(String key,
          {@required int defaultValue}) =>
      _preferences.getInt(key, defaultValue: defaultValue);

  Future<bool> setIntPreferenceValue(String key, int value) async =>
      await _preferences.setInt(key, value);

  Preference<bool> getBoolPreferenceStream(String key,
          {@required bool defaultValue}) =>
      _preferences.getBool(key, defaultValue: defaultValue);

  Future<bool> setBoolPreferenceValue(String key, bool value) async =>
      await _preferences.setBool(key, value);

  Future<bool> setJsonPreferences(
          String key, JsonPreferences preferencesObject) async =>
      await setJsonObjectAsString(key, preferencesObject.toJson());

  Stream<T> getJsonPreferencesStream<T>(
      String key, T jsonConverter(Map<String, dynamic> jsonData),
      {@required JsonPreferences defaultValue}) {
    return getJsonStream(key, defaultValue: defaultValue.toJson())
        .map((jsonObject) {
      return jsonObject != null ? jsonConverter(jsonObject) : null;
    });
  }

  Stream<Map<String, dynamic>> getJsonStream<T>(String key,
          {@required Map<String, dynamic> defaultValue}) =>
      getStringPreferenceStream(key, defaultValue: jsonEncode(defaultValue))
          .map((stringJson) => json.decode(stringJson));

  Future<bool> setJsonObjectAsString(
          String key, Map<String, dynamic> jsonObject) async =>
      await setStringValue(key, json.encode(jsonObject));


  bool getBoolPreference(String key, {@required bool defaultValue}) =>
      _preferences.getBool(key, defaultValue: defaultValue).getValue();

  String getStringPreference(String key, {@required String defaultValue}) =>
      _preferences.getString(key, defaultValue: defaultValue).getValue();

  int getIntPreference(String key, {@required int defaultValue}) =>
      _preferences.getInt(key, defaultValue: defaultValue).getValue();


  T getJsonPreferences<T>(
      String key, T jsonConverter(Map<String, dynamic> jsonData),
      {@required JsonPreferences defaultValue}) {
    var stringPreference = getStringPreference(key,
        defaultValue: json.encode(defaultValue.toJson()));
    var jsonObject = json.decode(stringPreference);
    return jsonObject != null ? jsonConverter(jsonObject) : null;
  }


}
