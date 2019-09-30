import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';

class AppIRCButtonSkinBloc extends ButtonSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCButtonSkinBloc(this.theme);

  Color get enabledColor => theme.platformSkinTheme.buttonColor;

  Color get disabledColor => theme.platformSkinTheme.disabledColor;
  Color get textColor => theme.platformSkinTheme.onPrimaryColor;
}
