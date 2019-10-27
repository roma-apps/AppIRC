import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class FormBooleanFieldSkinBloc extends SkinBloc {
  TextStyle get booleanRowLabelTextStyle;

  Color get switchActiveColor;
}
