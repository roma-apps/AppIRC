import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCChatAppBarSkinBloc extends ChatAppBarSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCChatAppBarSkinBloc(this.theme);

  @override
  TextStyle get titleTextStyle => theme.platformSkinTheme.textBoldMediumStyle;

  @override
  TextStyle get subTitleTextStyle =>
      theme.platformSkinTheme.textRegularSmallStyle;

  @override
  Color get appBarColor => theme.appBarColor;

  @override
  Color get iconAppBarColor => theme.onAppBarColor;
}
