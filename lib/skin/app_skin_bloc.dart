import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_model.dart';

class AppSkinBloc<T extends AppSkinTheme> extends SkinBloc {
  final T appSkinTheme;

  AppSkinBloc(this.appSkinTheme);

  static AppSkinBloc of(BuildContext context) => Provider.of<AppSkinBloc>(context);
}
