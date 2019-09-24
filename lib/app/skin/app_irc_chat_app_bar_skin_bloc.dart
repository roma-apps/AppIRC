import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/chat/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

class AppIRCChatAppBarSkinBloc extends ChatAppBarSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCChatAppBarSkinBloc(this.theme);

  TextStyle get titleTextStyle => theme.platformSkinTheme.textBoldMediumStyle.copyWith(color: theme.onAppBarColor);

  TextStyle get subTitleTextStyle => theme.platformSkinTheme.textRegularSmallStyle.copyWith(color: theme.onAppBarColor);
  Color get appBarColor => theme.appBarColor;
  Color get iconAppBarColor => theme.onAppBarColor;

}