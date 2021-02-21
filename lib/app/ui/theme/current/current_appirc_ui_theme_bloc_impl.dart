import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/current/current_appirc_ui_theme_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/dark/dark_appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/ui/theme/light/light_appirc_ui_theme_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/ui/theme/system/brightness/ui_theme_system_brightness_bloc.dart';
import 'package:rxdart/rxdart.dart';

class CurrentAppIrcUiThemeBloc extends DisposableOwner
    implements ICurrentAppIrcUiThemeBloc {
  final IUiThemeSystemBrightnessBloc systemBrightnessHandlerBloc;

  final List<IAppIrcUiTheme> availableThemes;
  final IUiSettingsBloc uiSettingsBloc;

  CurrentAppIrcUiThemeBloc({
    @required this.uiSettingsBloc,
    @required IAppIrcUiTheme lightTheme,
    @required IAppIrcUiTheme darkTheme,
    @required this.systemBrightnessHandlerBloc,
    @required this.availableThemes,
  });

  @override
  IAppIrcUiTheme get adaptiveBrightnessCurrentTheme =>
      _calculateAdaptiveBrightnessCurrentThemeStream(
        currentTheme,
        systemBrightnessHandlerBloc.systemBrightness,
      );

  @override
  Stream<IAppIrcUiTheme> get adaptiveBrightnessCurrentThemeStream {
    return Rx.combineLatest2(
      currentThemeStream,
      systemBrightnessHandlerBloc.systemBrightnessStream,
      (currentTheme, systemBrightness) =>
          _calculateAdaptiveBrightnessCurrentThemeStream(
        currentTheme,
        systemBrightness,
      ),
    ).distinct();
  }

  IAppIrcUiTheme _calculateAdaptiveBrightnessCurrentThemeStream(
      IAppIrcUiTheme currentTheme, Brightness systemBrightness) {
    if (currentTheme != null) {
      return currentTheme;
    } else {
      if (systemBrightness == null) {
        return null;
      }
      if (systemBrightness == Brightness.dark) {
        return darkAppIrcUiTheme;
      } else {
        return lightAppIrcUiTheme;
      }
    }
  }

  @override
  IAppIrcUiTheme get currentTheme => mapIdToTheme(uiSettingsBloc.themeId);

  @override
  Stream<IAppIrcUiTheme> get currentThemeStream =>
      uiSettingsBloc.themeIdStream.map(
        (currentUiThemeId) => mapIdToTheme(currentUiThemeId),
      );

  IAppIrcUiTheme mapIdToTheme(String id) {
    if (id == null) {
      return null;
    }

    return availableThemes.firstWhere(
      (theme) => theme.id == id,
    );
  }

  @override
  Future changeTheme(IAppIrcUiTheme theme) async {
    var newThemeId = theme?.id;
    if (uiSettingsBloc.themeId != newThemeId) {
      await uiSettingsBloc.changeThemeId(newThemeId);
    }
  }
}
