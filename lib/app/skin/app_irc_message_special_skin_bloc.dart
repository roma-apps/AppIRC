
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/special/message_special_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCSpecialMessageSkinBloc extends SpecialMessageSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCSpecialMessageSkinBloc(this.theme);

  @override
  TextStyle get defaultTextStyle => theme.platformSkinTheme.textRegularSmallStyle;

  @override
  Color get specialMessageColor => Colors.blue;



}
