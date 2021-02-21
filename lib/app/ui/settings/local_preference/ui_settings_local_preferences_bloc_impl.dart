import 'package:flutter_appirc/app/ui/settings/local_preference/ui_settings_local_preferences_bloc.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';

class UiSettingsLocalPreferencesBloc
    extends ObjectLocalPreferenceBloc<UiSettings>
    implements IUiSettingsLocalPreferencesBloc {
  UiSettingsLocalPreferencesBloc(
    ILocalPreferencesService preferencesService,
    String key,
  ) : super(
          preferencesService,
          key,
          1,
          (json) => UiSettings.fromJson(json),
        );
}
