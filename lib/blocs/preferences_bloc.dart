import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:flutter_appirc/service/preferences_service.dart';

typedef T DefaultValueGenerator<T>();

abstract class PreferencesBloc<T extends Preferences>
    extends AsyncOperationBloc {
  final PreferencesService _preferencesService;
  final String key;
  final T Function(Map<String, dynamic> jsonData) jsonConverter;
  final DefaultValueGenerator<T> defaultValueGenerator;

  PreferencesBloc(this._preferencesService, this.key, this.jsonConverter,
      this.defaultValueGenerator);

  T get preferenceOrNull => _preferencesService
      .getPreferences(key, jsonConverter, defaultValue: null);

  T get preferenceOrDefault => _preferencesService
      .getPreferences(key, jsonConverter, defaultValue: defaultValueGenerator());

  Future<bool> setNewPreferenceValue(T newValue) async {
    onOperationStarted();
    var result = await _preferencesService.setPreferences(key, newValue);
    onOperationFinished();
    return result;
  }

  bool get isSavedPreferenceExist =>
      _preferencesService.isPreferencesExist(key);

  Stream<T> get preferenceStream => _preferencesService
      .getPreferencesStream(key, jsonConverter, defaultValue: defaultValueGenerator());
}
