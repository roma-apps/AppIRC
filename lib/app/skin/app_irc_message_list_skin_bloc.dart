import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/list/message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCMessageListSkinBloc extends MessageListSkinBloc {
  final AppIRCSkinTheme theme;



  @override
  BoxDecoration highlightServerDecoration;

  AppIRCMessageListSkinBloc(this.theme) {
    highlightServerDecoration =
        BoxDecoration(color: theme.highlightServerBackgroundColor);
  }
}
