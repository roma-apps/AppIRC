import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCChatInputMessageSkinBloc extends ChatInputMessageSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCChatInputMessageSkinBloc(this.theme);

  TextStyle get inputMessageHintTextStyle =>
      theme.platformSkinTheme.textInputDecorationHintStyle;

  TextStyle get inputMessageTextStyle =>
      theme.platformSkinTheme.textEditTextStyle;

  Color get dividerColor => theme.platformSkinTheme.primaryColor;

  @override
  Color get cursorColor => theme.platformSkinTheme.backgroundColor;

  @override
  Color get iconSendMessageColor => theme.platformSkinTheme.backgroundColor;
}
