import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/form/form_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

class AppIRCFormSkinBloc extends FormSkinBloc {
  final AppIRCSkinTheme theme;


  AppIRCFormSkinBloc(this.theme);

  TextStyle get booleanRowLabelTextStyle => theme.platformSkinTheme.textRegularMediumStyle;

  TextStyle get textRowInputDecorationLabelTextStyle => theme.platformSkinTheme.textInputDecorationLabelStyle;

  TextStyle get textRowInputDecorationHintTextStyle => theme.platformSkinTheme.textInputDecorationHintStyle;
  TextStyle get textRowEditTextStyle => theme.platformSkinTheme.textEditTextStyle;

  TextStyle get titleTextStyle => theme.platformSkinTheme.textTitleStyle;

}