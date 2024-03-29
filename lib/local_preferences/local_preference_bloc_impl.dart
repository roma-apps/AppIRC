import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc_impl.dart';
import 'package:flutter_appirc/json/json_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:rxdart/rxdart.dart';

abstract class LocalPreferenceBloc<T> extends AsyncInitLoadingBloc
    implements IAsyncInitLoadingBloc, ILocalPreferenceBloc<T> {
  final ILocalPreferencesService _preferenceService;
  final String key;

  // ignore: close_sinks
  final BehaviorSubject<T> _subject = BehaviorSubject();

  @override
  T get value => _subject.value;

  @override
  Stream<T> get stream => _subject.stream;

  LocalPreferenceBloc(this._preferenceService, this.key) {
    addDisposable(subject: _subject);
  }

  T get defaultValue => null;

  @override
  Future internalAsyncInit() async {
    _subject.add((await getValueInternal()) ?? defaultValue);

    _preferenceService.listenKeyPreferenceChanged(
      key,
      (newValue) {
        if (value != newValue) {
          if (!_subject.isClosed) {
            _subject.add(newValue);
          }
        }
      },
    );
  }

  @override
  bool get isSavedPreferenceExist => _preferenceService.isKeyExist(key);

  @override
  Future<bool> clearValue() {
    var future = _preferenceService.clearValue(key);
    _subject.add(null);
    return future;
  }

  @override
  Future<bool> setValue(T newValue) {
    var future = setValueInternal(newValue);
    if (!_subject.isClosed) {
      _subject.add(newValue);
    }
    return future;
  }

  @override
  Future reload() async {
    _subject.add(await getValueInternal());
  }

  @protected
  Future<T> getValueInternal();

  @protected
  Future<bool> setValueInternal(T newValue);
}

abstract class ObjectLocalPreferenceBloc<T extends IJsonObject>
    extends LocalPreferenceBloc<T> {
  final T Function(Map<String, dynamic> jsonData) jsonConverter;
  final int schemaVersion;

  ObjectLocalPreferenceBloc(
    ILocalPreferencesService preferencesService,
    String key,
    this.schemaVersion,
    this.jsonConverter,
  ) : super(preferencesService, "$key.$schemaVersion");

  @override
  Future<bool> setValueInternal(T newValue) async {
    return await _preferenceService.setObjectPreference(key, newValue);
  }

  @override
  Future<T> getValueInternal() async =>
      _preferenceService.getObjectPreference(key, jsonConverter);
}

abstract class SimpleLocalPreferencesBloc<T> extends LocalPreferenceBloc<T> {
  SimpleLocalPreferencesBloc(
      ILocalPreferencesService preferencesService, String key)
      : super(preferencesService, key);
}

class IntPreferenceBloc extends SimpleLocalPreferencesBloc<int> {
  IntPreferenceBloc(ILocalPreferencesService preferencesService, String key)
      : super(preferencesService, key);

  @override
  Future<bool> setValueInternal(int newValue) async =>
      await _preferenceService.setIntPreference(key, newValue);

  @override
  Future<int> getValueInternal() async => _preferenceService.getIntPreference(
        key,
      );
}

class BoolLocalPreferenceBloc extends SimpleLocalPreferencesBloc<bool> {
  BoolLocalPreferenceBloc(
      ILocalPreferencesService preferencesService, String key)
      : super(preferencesService, key);

  @override
  Future<bool> setValueInternal(bool newValue) async =>
      await _preferenceService.setBoolPreference(key, newValue);

  @override
  Future<bool> getValueInternal() async => _preferenceService.getBoolPreference(
        key,
      );
}

class StringLocalPreferenceBloc extends SimpleLocalPreferencesBloc<String> {
  StringLocalPreferenceBloc(
      ILocalPreferencesService preferencesService, String key)
      : super(preferencesService, key);

  @override
  Future<bool> setValueInternal(String newValue) async =>
      await _preferenceService.setString(key, newValue);

  @override
  Future<String> getValueInternal() async =>
      _preferenceService.getStringPreference(
        key,
      );
}
