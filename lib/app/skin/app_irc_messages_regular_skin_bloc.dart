import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCMessagesRegularSkinBloc extends MessagesRegularSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCMessagesRegularSkinBloc(this.theme);

  TextStyle get regularMessageBodyTextStyle => theme.platformSkinTheme.textRegularSmallStyle;

  TextStyle modifyToLinkTextStyle(TextStyle textStyle) => textStyle.copyWith(color: theme.linkColor);

  TextStyle createNickTextStyle(Color color) =>
      theme.platformSkinTheme.textBoldSmallStyle.copyWith(color: color);

  TextStyle createDateTextStyle(Color color) =>
      theme.platformSkinTheme.textBoldSmallStyle.copyWith(color: color);

  TextStyle createMessageSubTitleTextStyle(Color color) =>
      theme.platformSkinTheme.textRegularSmallStyle.copyWith(color: color);

  Color findTitleColorDataForMessage(RegularMessageType messageType) =>
      theme.findMessageColorByType(messageType);

  @override
  Color get highlightBackgroundColor =>   theme.highlightBackgroundColor;
}
