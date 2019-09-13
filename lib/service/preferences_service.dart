import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

// library don't support null string default values
const String undefinedString = "";

class PreferencesService extends Providable {
  StreamingSharedPreferences _preferences;

  String getStringValue(String key, {@required String defaultValue}) =>
      getStringPreferenceStream(key, defaultValue: defaultValue).getValue();

  Preference<String> getStringPreferenceStream(String key,
      {@required String defaultValue}) =>
      _preferences.getString(key, defaultValue: defaultValue);

  Future<bool> setStringValue(String key, String value) async =>
      await _preferences.setString(key, value);

  bool isStringValueExist(String key) =>
      getStringValue(key, defaultValue: undefinedString) != undefinedString;


  int getIntValue(String key, {@required int defaultValue}) =>
      getIntPreferenceStream(key, defaultValue: defaultValue).getValue();


  int getIntPreference(String key,
      {@required int defaultValue}) =>
      getIntPreferenceStream(key, defaultValue: defaultValue).getValue();

  Preference<int> getIntPreferenceStream(String key,
      {@required int defaultValue}) =>
      _preferences.getInt(key, defaultValue: defaultValue);

  Future<bool> setIntPreferenceValue(String key, int value) async =>
      await _preferences.setInt(key, value);

  bool isIntValueExist(String key) =>
      getIntValue(key, defaultValue: null) != null;


  bool getBoolValue(String key, {@required bool defaultValue}) =>
      getBoolPreferenceStream(key, defaultValue: defaultValue).getValue();


  bool getBoolPreference(String key,
      {@required bool defaultValue}) =>
      getBoolPreferenceStream(key, defaultValue: defaultValue).getValue();

  Preference<bool> getBoolPreferenceStream(String key,
      {@required bool defaultValue}) =>
      _preferences.getBool(key, defaultValue: defaultValue);

  Future<bool> setBoolPreferenceValue(String key, bool value) async =>
      await _preferences.setBool(key, value);

  bool isBoolValueExist(String key) =>
      getBoolValue(key, defaultValue: null) != null;

  bool isJsonValueExist(String key) => isStringValueExist(key);

  Future<bool> setJsonPreferences(String key,
      JsonPreferences preferencesObject) async =>
      await setJsonObjectAsString(key, preferencesObject.toJson());

  bool isPreferencesExist(String key) => isJsonValueExist(key);

  T getJsonPreferences<T extends JsonPreferences>(String key,
      T jsonConverter(Map<String, dynamic> jsonData),
      {@required T defaultValue}) {
    var jsonObjectAsString = getJsonObjectAsString(key,
        defaultValue:
        defaultValue != null ? defaultValue.toJson() : defaultValue);
    return jsonObjectAsString != null
        ? jsonConverter(jsonObjectAsString)
        : null;
  }

  Stream<T> getJsonPreferencesStream<T>(String key,
      T jsonConverter(Map<String, dynamic> jsonData),
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

  Future<bool> setJsonObjectAsString(String key,
      Map<String, dynamic> jsonObject) async =>
      await setStringValue(key, json.encode(jsonObject));

  Map<String, dynamic> getJsonObjectAsString(String key,
      {@required Map<String, dynamic> defaultValue}) {
    String defaultValueString;
    if (defaultValue != null) {
      defaultValueString = json.encode(defaultValue);
    } else {
      defaultValueString = undefinedString;
    }

    var jsonString = getStringValue(key, defaultValue: defaultValueString);

    Map<String, dynamic> jsonObject;
    if (jsonString != null && jsonString.isNotEmpty) {
      jsonObject = json.decode(jsonString);
    }

    return jsonObject;
  }

  Future init() async {
    _preferences = await StreamingSharedPreferences.instance;
  }

  @override
  void dispose() {
    _preferences = null;
  }

  void clear() {
    _preferences.clear();
  }

  deletePreferencesValue(String key) async {
    if (isPreferencesExist(key)) {
      _preferences.remove(key);
    }
  }
}
