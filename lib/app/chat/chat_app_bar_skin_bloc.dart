import 'package:flutter/painting.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class ChatAppBarSkinBloc extends SkinBloc {
  TextStyle get titleTextStyle;

  TextStyle get subTitleTextStyle;

  Color get appBarColor;
  Color get iconAppBarColor;

}