import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class ChatInputMessageSkinBloc extends SkinBloc {
  TextStyle get inputMessageHintTextStyle;

  TextStyle get inputMessageTextStyle;

  Color get iconSendMessageColor;
  Color get cursorColor;

  Color get dividerColor;
}
