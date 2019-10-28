import 'package:flutter/painting.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class MessageListSkinBloc extends SkinBloc {
  Color get searchBackgroundColor;

  BoxDecoration get highlightSearchDecoration;

  BoxDecoration get highlightServerDecoration;
}
