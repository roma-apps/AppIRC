import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/localization/settings/local_preference/localization_settings_local_preferences_bloc.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_bloc.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/localization/localization_model.dart';

class LocalizationSettingsBloc extends DisposableOwner
    implements ILocalizationSettingsBloc {
  ILocalizationSettingsLocalPreferencesBloc
      localizationSettingsLocalPreferencesBloc;

  LocalizationSettingsBloc({
    @required this.localizationSettingsLocalPreferencesBloc,
  });

  @override
  LocalizationSettings get settingsData =>
      localizationSettingsLocalPreferencesBloc.value;

  @override
  Stream<LocalizationSettings> get settingsDataStream =>
      localizationSettingsLocalPreferencesBloc.stream;

  @override
  LocalizationLocale get localizationLocale => settingsData.localizationLocale;

  @override
  Stream<LocalizationLocale> get localizationLocaleStream =>
      settingsDataStream.map((settings) => settings.localizationLocale);

  @override
  void changeLocalizationLocale(LocalizationLocale value) {
    updateSettings(
      LocalizationSettings(localizationLocale: value),
      // copyWith don't set null values
      // settingsData.copyWith(localizationLocale: value),
    );
  }

  @override
  Future updateSettings(LocalizationSettings newSettings) async {
    await localizationSettingsLocalPreferencesBloc.setValue(
      newSettings,
    );
  }
}
