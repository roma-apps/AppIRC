import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_model.dart';

const String _preferenceKey = "skin";

class AppSkinPreferenceBloc<T extends AppSkinTheme> extends Providable {
  final PreferencesService preferencesService;
  final T defaultSkin;
  final List<T> allAvailableSkins;

  StringPreferencesBloc _skinPreferenceBloc;

  Stream<T> get appSkinStream => _skinPreferenceBloc
      .valueStream(defaultValue: defaultSkin.id)
      .map(_map)
      .distinct();

  T get currentAppSkinTheme =>
      _map(_skinPreferenceBloc.getValue(defaultValue: defaultSkin.id));

  set currentAppSkinTheme(T newValue) =>
      _skinPreferenceBloc.setValue(newValue.id);

  T _map(skinId) {
    if (skinId == null) {
      return defaultSkin;
    } else {
      var skin = allAvailableSkins.firstWhere((skin) => skin.id == skinId,
          orElse: () => null);
      skin ??= defaultSkin;

      return skin;
    }
  }

  AppSkinPreferenceBloc(
      this.preferencesService, this.allAvailableSkins, this.defaultSkin) {
    _skinPreferenceBloc =
        StringPreferencesBloc(preferencesService, _preferenceKey);
    addDisposable(disposable: _skinPreferenceBloc);
  }
}
