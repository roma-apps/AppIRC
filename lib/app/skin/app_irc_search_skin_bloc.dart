import 'package:flutter/painting.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_skin_bloc.dart';

import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';

class AppIRCMessageListSearchSkinBloc extends SearchSkinBloc {
  final AppIRCSkinTheme theme;

  @override
  BoxDecoration searchBoxDecoration;

  AppIRCMessageListSearchSkinBloc(this.theme) {
    searchBoxDecoration =
        BoxDecoration(color: theme.searchBackgroundColor);
  }

  @override
  Color get disabledColor => theme.disabledColor;
  @override
  Color get iconColor => theme.platformSkinTheme.textRegularSmallStyle.color;
}
