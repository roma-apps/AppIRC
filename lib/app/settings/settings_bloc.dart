import 'package:flutter_appirc/app/settings/settings_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';

abstract class ISettingsBloc<T extends ISettings> implements IDisposable {
  T get settingsData;

  Stream<T> get settingsDataStream;

  Future updateSettings(T newSettings);
}
