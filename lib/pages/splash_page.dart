import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/widgets.dart';
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
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
import 'package:flutter_appirc/widgets/lounge_new_connection_widget.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

var _logger = MyLogger(logTag: "SplashPage", enabled: true);

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
    var appLocalizations = AppLocalizations.of(context);
    var uiSkin = Provider.of<UISkin>(context);

    return PlatformScaffold(
        appBar: PlatformAppBar(title: Text(appLocalizations.tr("app_name"))),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(appLocalizations.tr("splash.loading")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SpinKitRotatingCircle(
                    color: uiSkin.appSkin.accentColor,
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

    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);
    var ircNetworksPreferencesBloc =
        Provider.of<IRCNetworksPreferencesBloc>(context);

    var isSavedLoungePreferenceExist =
        loungePreferencesBloc.isSavedPreferenceExist;

    _logger.i(() =>
        "init isSavedLoungePreferenceExist $isSavedLoungePreferenceExist");

    Widget nextPage;

    if (isSavedLoungePreferenceExist) {
      var connected = await connectToLounge(
        context,
        LoungeNewConnectionBloc(
            loungeService: loungeService,
            preferencesBloc: loungePreferencesBloc,
            newLoungePreferences: loungePreferencesBloc.preferenceOrDefault),
      );

      _logger.i(() => "init connectedLounge $connected");

      if (connected) {
        var isSavedIRCNetworksPreferenceExist =
            ircNetworksPreferencesBloc.isSavedPreferenceExist;

        _logger.i(() => "init isSavedIRCNetworksPreferenceExist"
            " $isSavedIRCNetworksPreferenceExist");

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

          nextPage = IRCChatPage();
        } else {
          nextPage = IRCNetworksNewConnectionPage(isOpenedFromAppStart: true);
        }
      } else {
        nextPage = IRCChatPage();
      }
    } else {
      nextPage = LoungeNewConnectionPage();
    }

    Navigator.pushReplacement(
        context, platformPageRoute(builder: (context) => nextPage, maintainState: false));
  }
}
