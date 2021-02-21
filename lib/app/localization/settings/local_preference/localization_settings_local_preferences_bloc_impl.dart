import 'package:flutter_appirc/app/localization/settings/local_preference/localization_settings_local_preferences_bloc.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';

class LocalizationSettingsLocalPreferencesBloc
    extends ObjectLocalPreferenceBloc<LocalizationSettings>
    implements ILocalizationSettingsLocalPreferencesBloc {
  LocalizationSettingsLocalPreferencesBloc(
    ILocalPreferencesService preferencesService,
    String key,
  ) : super(
          preferencesService,
          key,
          1,
          (json) => LocalizationSettings.fromJson(json),
        );
}
