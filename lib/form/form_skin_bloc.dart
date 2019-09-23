import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class FormSkinBloc extends SkinBloc {
  TextStyle get booleanRowLabelTextStyle;

  TextStyle get textRowInputDecorationLabelTextStyle;

  TextStyle get textRowInputDecorationHintTextStyle;
  TextStyle get textRowEditTextStyle;

  TextStyle get titleTextStyle;

}