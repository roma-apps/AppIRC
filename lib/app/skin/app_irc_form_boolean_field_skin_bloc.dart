import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/form/field/boolean/form_boolean_field_skin_bloc.dart';

class AppIRCFormBooleanFieldSkinBloc extends FormBooleanFieldSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCFormBooleanFieldSkinBloc(this.theme);

  @override
  Color get switchActiveColor => theme.platformSkinTheme.buttonColor;

  @override
  TextStyle get booleanRowLabelTextStyle =>
      theme.platformSkinTheme.textRegularMediumStyle;
}
