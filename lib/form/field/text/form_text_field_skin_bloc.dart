import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class FormTextFieldSkinBloc extends SkinBloc {
  TextStyle get labelStyle;

  TextStyle get hintStyle;

  TextStyle get editStyle;

  TextStyle get errorStyle;

  TextStyle get disabledLabelStyle;

  TextStyle get disabledHintStyle;

  TextStyle get disabledEditStyle;
}
