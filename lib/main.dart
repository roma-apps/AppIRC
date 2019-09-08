import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/pages/lounge_connection_page.dart';
import 'package:flutter_appirc/pages/splash_page.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
import 'package:logger_flutter/logger_flutter.dart';

var _logTag = "Main";

var socketIOManager = SocketIOManager();

var loungeService = LoungeService(socketIOManager);
var chatBloc = ChatBloc(loungeService);
var preferencesService = PreferencesService();

Future main() async {
  runApp(EasyLocalization(child: AppIRC()));
}

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider
        .of(context)
        .data;

    var loungeConnectionPreferencesBloc =
    LoungePreferencesBloc(preferencesService);
    var ircNetworksPreferencesBloc =
    IRCNetworksPreferencesBloc(preferencesService);
    return Provider(
      bloc: preferencesService,
      child: Provider<LoungePreferencesBloc>(
        bloc: loungeConnectionPreferencesBloc,
        child: Provider<IRCNetworksPreferencesBloc>(
          bloc: ircNetworksPreferencesBloc,
          child: Provider(
            bloc: loungeService,
            child: EasyLocalizationProvider(
              data: data,
              child: Provider<ChatBloc>(
                  bloc: chatBloc,
                  child: MaterialApp(
                      title: "AppIRC",
                      localizationsDelegates: [
                        //app-specific localization
                        EasylocaLizationDelegate(
                            locale: data.locale, path: 'assets/langs'),
                      ],
                      supportedLocales: [Locale('en', 'US')],
                      locale: data.savedLocale,
                      theme: ThemeData(
                        primarySwatch: Colors.red,
                      ),
                      home: SplashPage()
                  )),
            ),
          ),
        ),
      ),
    );
  }
}
