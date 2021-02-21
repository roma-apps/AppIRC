import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc.dart';
import 'package:provider/provider.dart';

abstract class ILocalizationSettingsLocalPreferencesBloc
    implements ILocalPreferenceBloc<LocalizationSettings> {
  static ILocalizationSettingsLocalPreferencesBloc of(BuildContext context,
      {bool listen = true}) =>
      Provider.of<ILocalizationSettingsLocalPreferencesBloc>(context, listen: listen);
}
