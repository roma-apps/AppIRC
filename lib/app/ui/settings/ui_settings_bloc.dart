import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/settings/settings_bloc.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_model.dart';
import 'package:provider/provider.dart';

abstract class IUiSettingsBloc implements ISettingsBloc<UiSettings> {
  static IUiSettingsBloc of(BuildContext context, {bool listen = true}) =>
      Provider.of<IUiSettingsBloc>(context, listen: listen);

  String get themeId;

  Stream<String> get themeIdStream;

  void changeThemeId(String value);
}
