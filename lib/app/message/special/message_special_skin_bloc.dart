import 'package:flutter/painting.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class SpecialMessageSkinBloc extends SkinBloc {

  TextStyle get defaultTextStyle;
  Color get specialMessageColor;
}
