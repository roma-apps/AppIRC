import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';

class AppIRCTextSkinBloc extends TextSkinBloc {
  final AppIRCSkinTheme theme;

  @override
  TextStyle defaultItalicTextStyle;

  AppIRCTextSkinBloc(this.theme) {
    defaultItalicTextStyle =
        defaultTextStyle.copyWith(fontStyle: FontStyle.italic);
  }

  @override
  TextStyle get defaultTextStyle => theme.defaultTextStyle;

}
