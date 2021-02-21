import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/ui/settings/local_preference/ui_settings_local_preferences_bloc.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_bloc.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

class UiSettingsBloc extends DisposableOwner implements IUiSettingsBloc {
  final IUiSettingsLocalPreferencesBloc uiSettingsLocalPreferencesBloc;

  UiSettingsBloc({
    @required this.uiSettingsLocalPreferencesBloc,
  });

  @override
  UiSettings get settingsData => uiSettingsLocalPreferencesBloc.value;

  @override
  Stream<UiSettings> get settingsDataStream =>
      uiSettingsLocalPreferencesBloc.stream;

  @override
  String get themeId => settingsData?.themeId;

  @override
  Stream<String> get themeIdStream =>
      settingsDataStream.map((settings) => settings?.themeId);

  @override
  void changeThemeId(String value) {
    updateSettings(
      // copyWith don't set null values
      UiSettings(themeId: value),
    );
  }

  @override
  Future updateSettings(UiSettings newSettings) async {
    await uiSettingsLocalPreferencesBloc.setValue(
      newSettings,
    );
  }
}
