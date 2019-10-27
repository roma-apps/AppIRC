import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_skin_bloc.dart';

class AppIRCFormTextFieldSkinBloc extends FormTextFieldSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCFormTextFieldSkinBloc(this.theme);

  @override
  TextStyle get labelStyle => theme.platformSkinTheme.textInputDecorationLabelStyle;

  @override
  TextStyle get hintStyle => theme.platformSkinTheme.textInputDecorationHintStyle;

  @override
  TextStyle get editStyle => theme.platformSkinTheme.textEditTextStyle;

  @override
  TextStyle get errorStyle => theme.platformSkinTheme
      .textInputDecorationErrorStyle;

  @override
  TextStyle get disabledLabelStyle => labelStyle.copyWith(color: Colors.grey);

  @override
  TextStyle get disabledHintStyle => hintStyle.copyWith(color: Colors.grey);

  @override
  TextStyle get disabledEditStyle => editStyle.copyWith(color: Colors.grey);

}
