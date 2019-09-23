import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

class AppSkinBloc<T extends AppIRCSkinTheme> extends SkinBloc {
  final T appSkinTheme;

  AppSkinBloc(this.appSkinTheme);
}
