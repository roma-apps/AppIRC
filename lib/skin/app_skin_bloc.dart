import 'package:flutter_appirc/skin/skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_model.dart';

class AppSkinBloc<T extends AppSkinTheme> extends SkinBloc {
  final T appSkinTheme;

  AppSkinBloc(this.appSkinTheme);

}
