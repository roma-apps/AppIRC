import 'dart:ui';

import 'package:flutter_appirc/app/message/messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCMessagesSpecialSkinBloc extends MessagesSpecialSkinBloc {
  final AppIRCSkinTheme theme;

  AppIRCMessagesSpecialSkinBloc(this.theme);

  @override
  Color get linkColor => theme.linkColor;
}
