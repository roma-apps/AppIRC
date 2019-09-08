import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/pages/chat_page.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/pages/lounge_connection_page.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger_flutter/logger_flutter.dart';

var _logTag = "SplashPage";

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
        AppBar(title: Text(AppLocalizations.of(context).tr("app_name"))),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Text(AppLocalizations.of(context).tr("splash.loading")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SpinKitRotatingCircle(
                    color: Colors.red,
                    size: 50.0,
                  ),
                )
              ]),
        ));
  }


  Future init(BuildContext context) async {
    var loungeService = Provider.of<LoungeService>(context);

    var preferencesService = Provider.of<PreferencesService>(context);

    await preferencesService.init();
//  preferencesService.clear();
    LogConsole.init(bufferSize: 100);

    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);
    var ircNetworksPreferencesBloc =
    Provider.of<IRCNetworksPreferencesBloc>(context);

    var isSavedLoungePreferenceExist =
        loungePreferencesBloc.isSavedPreferenceExist;

    logi(_logTag,
        "init isSavedLoungePreferenceExist $isSavedLoungePreferenceExist");

    Widget nextPage;

    if (isSavedLoungePreferenceExist) {
      var connected = await connectToLounge(
        context,
        NewLoungeConnectionBloc(
            loungeService: loungeService,
            preferencesBloc: loungePreferencesBloc,
            newConnectionPreferences: loungePreferencesBloc
                .preferenceOrDefault),
      );

      logi(_logTag, "init connectedLounge $connected");

      if (connected) {
        var isSavedIRCNetworksPreferenceExist =
            ircNetworksPreferencesBloc.isSavedPreferenceExist;

        logi(_logTag,
            "init isSavedIRCNetworksPreferenceExist $isSavedIRCNetworksPreferenceExist");

        if (isSavedIRCNetworksPreferenceExist) {
          var networksPreferences =
              ircNetworksPreferencesBloc.preferenceOrDefault;

          for (IRCNetworkPreferences networkPreferences
          in networksPreferences.networks) {
            var ircNetworksNewConnectionBloc = IRCNetworksNewConnectionBloc(
                loungeService: loungeService,
                preferencesBloc: ircNetworksPreferencesBloc,
                newConnectionPreferences: networkPreferences);
            await ircNetworksNewConnectionBloc.sendNewNetworkRequest();
          }

          nextPage = ChatPage();
        } else {
          nextPage = IRCNetworksNewConnectionPage(isOpenedFromAppStart: true);
        }
      } else {
        nextPage = ChatPage();
      }
    } else {
      nextPage = LoungeConnectionPage();
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => nextPage));
  }
}
