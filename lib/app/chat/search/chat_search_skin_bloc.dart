import 'package:flutter/painting.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class SearchSkinBloc extends SkinBloc {

  BoxDecoration get searchBoxDecoration;
  Color get disabledColor;
  Color get iconColor;
}
