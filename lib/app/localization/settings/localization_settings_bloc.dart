import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_model.dart';
import 'package:flutter_appirc/app/settings/settings_bloc.dart';
import 'package:flutter_appirc/localization/localization_model.dart';
import 'package:provider/provider.dart';

abstract class ILocalizationSettingsBloc
    implements ISettingsBloc<LocalizationSettings> {
  static ILocalizationSettingsBloc of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<ILocalizationSettingsBloc>(context, listen: listen);

  LocalizationLocale get localizationLocale;

  Stream<LocalizationLocale> get localizationLocaleStream;

  void changeLocalizationLocale(LocalizationLocale value);
}
