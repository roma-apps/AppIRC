import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';


const String emptyString = "";

class PreferencesService extends Providable {
  StreamingSharedPreferences _preferences;

  String _getStringValue(String key, {@required String defaultValue}) =>
      _getStringPreferenceStream(key, defaultValue: defaultValue).getValue();

  Preference<String> _getStringPreferenceStream(String key,
          {@required String defaultValue}) =>
      _preferences.getString(key, defaultValue: defaultValue);

  Future<bool> _setStringValue(String key, String value) async =>
      await _preferences.setString(key, value);

  bool _isStringValueExist(String key) =>
      _getStringValue(key, defaultValue: emptyString) != emptyString;

  bool isJsonValueExist(String key) => _isStringValueExist(key);

  Future<bool> setPreferences(
          String key, Preferences preferencesObject) async =>
      await setJsonObjectAsString(key, preferencesObject.toJson());


  bool isPreferencesExist(String key) => isJsonValueExist(key);



  T getPreferences<T extends Preferences>(
          String key, T jsonConverter(Map<String, dynamic> jsonData),
          {@required T defaultValue}) =>
      jsonConverter(getJsonObjectAsString(key,
          defaultValue:
              defaultValue != null ? defaultValue.toJson() : defaultValue));

  Stream<T> getPreferencesStream<T>(
      String key, T jsonConverter(Map<String, dynamic> jsonData),
      {@required Preferences defaultValue}) {
    return getJsonStream(key, defaultValue: defaultValue.toJson())
        .map((jsonObject) => jsonConverter(jsonObject));
  }

  Stream<Map<String, dynamic>> getJsonStream<T>(String key,
          {@required Map<String, dynamic> defaultValue}) =>
      _getStringPreferenceStream(key, defaultValue: jsonEncode(defaultValue))
          .map((stringJson) => json.decode(stringJson));

  Future<bool> setJsonObjectAsString(
          String key, Map<String, dynamic> jsonObject) async =>
      await _setStringValue(key, json.encode(jsonObject));

  Map<String, dynamic> getJsonObjectAsString(String key,
      {@required Map<String, dynamic> defaultValue}) {
    String defaultValueString;
    if (defaultValue != null) {
      defaultValueString = json.encode(defaultValue);
    } else {
      defaultValueString = emptyString;
    }

    var jsonString = _getStringValue(key, defaultValue: defaultValueString);

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
}
