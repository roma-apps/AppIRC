import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class FormSkinBloc extends SkinBloc {
  TextStyle get booleanRowLabelTextStyle;
  Color get switchActiveColor;

  TextStyle get textRowInputDecorationLabelTextStyle;

  TextStyle get textRowInputDecorationHintTextStyle;
  TextStyle get textRowEditTextStyle;

  TextStyle get titleTextStyle;

}
