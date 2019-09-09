import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/pages/splash_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoThemeData;
import 'package:flutter/material.dart' show ThemeData, Colors, Icons;

import 'blocs/irc_chat_bloc.dart';

var socketIOManager = SocketIOManager();

var loungeService = LoungeService(socketIOManager);
var chatBloc = IRCChatBloc(loungeService);
var preferencesService = PreferencesService();

Future main() async {
  runApp(EasyLocalization(
      child: AppIRC()));
}

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    var accentColor = Colors.red;
    final themeData = new ThemeData(
      primarySwatch: accentColor,
    );

    final cupertinoTheme = new CupertinoThemeData(
      primaryColor: accentColor,
    );

    var uiSkin = UISkin(
        themeData, cupertinoTheme);


    var data = EasyLocalizationProvider.of(context).data;

    var loungeConnectionPreferencesBloc =
        LoungePreferencesBloc(preferencesService);
    var ircNetworksPreferencesBloc =
        IRCNetworksPreferencesBloc(preferencesService);

    return Provider(
      bloc: uiSkin,
      child: Provider(
        bloc: preferencesService,
        child: Provider<LoungePreferencesBloc>(
          bloc: loungeConnectionPreferencesBloc,
          child: Provider<IRCNetworksPreferencesBloc>(
            bloc: ircNetworksPreferencesBloc,
            child: Provider(
              bloc: loungeService,
              child: EasyLocalizationProvider(
                data: data,
                child: Provider<IRCChatBloc>(
                    bloc: chatBloc,
                    child: PlatformApp(
                        title: "AppIRC",
                        localizationsDelegates: [
                          //app-specific localization
                          EasylocaLizationDelegate(
                              locale: data.locale, path: 'assets/langs'),
                        ],
                        supportedLocales: [Locale('en', 'US')],
                        locale: data.savedLocale,

                        android: (_) => MaterialAppData(theme: themeData),
                        ios: (_) => new CupertinoAppData(theme: cupertinoTheme),
                        home: SplashPage())),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
