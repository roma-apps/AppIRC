import 'dart:ui';

import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/skin/popup_menu_skin_bloc.dart';

class AppIRCPopupMenuSkinBloc extends PopupMenuSkinBloc {
  final AppIRCSkinTheme theme;
  AppIRCPopupMenuSkinBloc(this.theme);

  Color get backgroundColor => theme.backgroundColor;
}
