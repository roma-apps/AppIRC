import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:provider/provider.dart';

abstract class ICurrentAppIrcUiThemeBloc implements IDisposable {
  static ICurrentAppIrcUiThemeBloc of(BuildContext context,
          {bool listen = true}) =>
      Provider.of<ICurrentAppIrcUiThemeBloc>(context, listen: listen);

  IAppIrcUiTheme get adaptiveBrightnessCurrentTheme;

  Stream<IAppIrcUiTheme> get adaptiveBrightnessCurrentThemeStream;

  IAppIrcUiTheme get currentTheme;

  Stream<IAppIrcUiTheme> get currentThemeStream;

  Future changeTheme(IAppIrcUiTheme theme);
}
