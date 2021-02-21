import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/ui/theme/ui_theme_model.dart';
import 'package:provider/provider.dart';

class AppIrcUiThemeProxyProvider extends StatelessWidget {
  final Widget child;

  AppIrcUiThemeProxyProvider({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) => ProxyProvider<IAppIrcUiTheme, IUiTheme>(
        update: (context, value, previous) => value,
        child: ProxyProvider<IAppIrcUiTheme, IAppIrcUiColorTheme>(
          update: (context, value, previous) => value.colorTheme,
          child: ProxyProvider<IAppIrcUiTheme, IAppIrcUiTextTheme>(
            update: (context, value, previous) => value.textTheme,
            child: child,
          ),
        ),
      );
}
