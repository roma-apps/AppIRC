import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/form/form_title_skin_bloc.dart';

class AppIRCFormTitleSkinBloc extends FormTitleSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCFormTitleSkinBloc(this.theme);

  @override
  TextStyle get titleTextStyle => theme.platformSkinTheme.textTitleStyle;
}
