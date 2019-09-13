import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoThemeData;
import 'package:flutter/material.dart' show ThemeData, Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/pages/irc_chat_page.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/pages/lounge_new_connection_page.dart';
import 'package:flutter_appirc/pages/splash_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';
import 'package:flutter_appirc/widgets/lounge_preferences_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "Main", enabled: true);

var socketIOManager = SocketIOManager();

var loungeService = LoungeService(socketIOManager);
var preferencesService = PreferencesService();

var loungePreferencesBloc = LoungePreferencesBloc(preferencesService);
var ircNetworksPreferencesBloc = IRCNetworksPreferencesBloc(preferencesService);

var networksListBloc =
    IRCNetworksListBloc(loungeService, ircNetworksPreferencesBloc);

Future main() async {
  var appIRC = AppIRC();
  runApp(EasyLocalization(child: appIRC));
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

    var uiSkin = UISkin(themeData, cupertinoTheme);

    var data = EasyLocalizationProvider.of(context).data;

    return Provider(
      bloc: uiSkin,
      child: Provider(
        bloc: preferencesService,
        child: Provider<LoungePreferencesBloc>(
          bloc: loungePreferencesBloc,
          child: Provider<IRCNetworksPreferencesBloc>(
            bloc: ircNetworksPreferencesBloc,
            child: Provider(
              bloc: loungeService,
              child: EasyLocalizationProvider(
                data: data,
                child: Provider<IRCNetworksPreferencesBloc>(
                  bloc: IRCNetworksPreferencesBloc(preferencesService),
                  child: Provider<IRCNetworksListBloc>(
                    bloc: networksListBloc,
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
                        home: SplashPage(init)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

init(BuildContext context) async {
  _logger.d(() => "init");

  await preferencesService.init();

//    preferencesService.clear();

  var isSavedLoungePreferenceExist =
      loungePreferencesBloc.isSavedPreferenceExist;

  _logger.i(
      () => "init isSavedLoungePreferenceExist $isSavedLoungePreferenceExist");

  Widget nextPage;

  if (isSavedLoungePreferenceExist) {
    var connected = await connectToLounge(
      context,
      LoungeNewConnectionBloc(
          loungeService: loungeService,
          preferencesBloc: loungePreferencesBloc,
          newLoungePreferences: loungePreferencesBloc.getPreferenceOrDefault()),
    );

    _logger.i(() => "init connectedLounge $connected");

    if (connected) {
      var isSavedIRCNetworksPreferenceExist =
          ircNetworksPreferencesBloc.isSavedPreferenceExist;

      _logger.i(() => "init isSavedIRCNetworksPreferenceExist"
          " $isSavedIRCNetworksPreferenceExist");

      try {
        if (isSavedIRCNetworksPreferenceExist) {
          var networksPreferences =
              ircNetworksPreferencesBloc.getPreferenceOrDefault();

          // delete old value to avoid duplicates
          // TODO: Refactor
          ircNetworksPreferencesBloc.deleteValue();

          for (IRCNetworkPreferences networkPreferences
              in networksPreferences.networks) {
            var ircNetworksNewConnectionBloc = IRCNetworksNewConnectionBloc(
                loungeService: loungeService,
                preferencesBloc: ircNetworksPreferencesBloc,
                newConnectionPreferences: networkPreferences);
            await ircNetworksNewConnectionBloc.sendNewNetworkRequest();
          }

          nextPage = IRCChatPage();
        } else {
          nextPage = IRCNetworksNewConnectionPage(isOpenedFromAppStart: true);
        }
      } on Exception catch (e) {
        ircNetworksPreferencesBloc.deleteValue();
        // TODO: handle migration between version
        _logger.e(() => "Error during parsing preferences $e");
        nextPage = IRCNetworksNewConnectionPage(isOpenedFromAppStart: true);
      }
    } else {
      nextPage = IRCChatPage();
    }
  } else {
    nextPage = LoungeNewConnectionPage();
  }

  Navigator.pushReplacement(context,
      platformPageRoute(builder: (context) => nextPage, maintainState: false));
}
