import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCMessageListSearchSkinBloc extends MessageListSearchSkinBloc {
  final AppIRCSkinTheme theme;

  @override
  BoxDecoration searchBoxDecoration;

  AppIRCMessageListSearchSkinBloc(this.theme) {
    searchBoxDecoration =
        BoxDecoration(color: theme.platformSkinTheme.secondaryColor);
  }

  @override
  Color get disabledColor => theme.searchBackgroundColor;
}
