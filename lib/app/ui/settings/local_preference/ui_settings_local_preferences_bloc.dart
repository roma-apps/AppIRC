import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc.dart';
import 'package:provider/provider.dart';

abstract class IUiSettingsLocalPreferencesBloc
    implements ILocalPreferenceBloc<UiSettings> {
  static IUiSettingsLocalPreferencesBloc of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<IUiSettingsLocalPreferencesBloc>(context, listen: listen);
}
