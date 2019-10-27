import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_skin_bloc.dart';

class AppIRCFormTextFieldSkinBloc extends FormTextFieldSkinBloc {
  final AppIRCSkinTheme theme;

  @override
  TextStyle disabledLabelStyle;

  @override
  TextStyle disabledHintStyle;

  @override
  TextStyle disabledEditStyle;

  AppIRCFormTextFieldSkinBloc(this.theme) {
    disabledLabelStyle = labelStyle.copyWith(color: theme.disabledTextColor);

    disabledHintStyle = hintStyle.copyWith(color: theme.disabledTextColor);

    disabledEditStyle = editStyle.copyWith(color: theme.disabledTextColor);
  }

  @override
  TextStyle get labelStyle => theme.platformSkinTheme.textInputDecorationLabelStyle;

  @override
  TextStyle get hintStyle => theme.platformSkinTheme.textInputDecorationHintStyle;

  @override
  TextStyle get editStyle => theme.platformSkinTheme.textEditTextStyle;

  @override
  TextStyle get errorStyle => theme.platformSkinTheme
      .textInputDecorationErrorStyle;

}
