import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/async/async_dialog_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';

class AppIRCProgressDialogSkinBloc extends ProgressDialogSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCProgressDialogSkinBloc(this.theme);

  @override
  Color get backgroundColor => theme.appBackgroundColor;

  @override
  TextStyle get messageTextStyle => theme.platformSkinTheme
      .textRegularMediumStyle;

}
