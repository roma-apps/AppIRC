import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_new_connection_page.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_defaults.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/irc_chat_page.dart';
import 'package:flutter_appirc/app/networks/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/app/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';


var _logger = MyLogger(logTag: "Main", enabled: true);
var socketIOManager = SocketIOManager();

Future main() async => runApp(AppIRC());

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider<PreferencesService>(
        bloc: PreferencesService(),
        child: Provider<LoungePreferencesBloc>(
          bloc: LoungePreferencesBloc(Provider.of<PreferencesService>(context)),
          child: StreamBuilder<LoungePreferences>(
              stream: Provider.of<LoungePreferencesBloc>(context)
                  .valueStream(createDefaultLoungePreferences(context)),
              builder: (context, snapshot) {
                var loungePreferences = snapshot.data;
                return Provider<ChatBackendService>(
                  bloc:
                      LoungeBackendService(socketIOManager, loungePreferences),
                  child: Provider(
                    bloc: ChatPreferencesBloc(
                        Provider.of<PreferencesService>(context)),
                    child: Provider<ChatBloc>(
                      bloc: ChatBloc(
                          Provider.of<LoungeBackendService>(context),
                          () async =>
                              await _getSavedChatPreferencesOrNull(context)),
                      child: Provider<AppSkinBloc>(
                        bloc: AppSkinBloc(
                            Provider.of<PreferencesService>(context)),
                        child: StreamBuilder<UISkin>(
                            stream:
                                Provider.of<AppSkinBloc>(context).skinStream,
                            builder: (context, snapshot) {
                              var uiSkin = snapshot.data;
                              if (uiSkin == null) {
                                uiSkin = createDefaultUISkin();
                              }
                              return EasyLocalization(
                                child: buildApp(context, uiSkin),
                              );
                            }),
                      ),
                    ),
                  ),
                );
              }),
        ),
      );

  buildApp(BuildContext context, UISkin uiSkin) {
    var data = EasyLocalizationProvider.of(context).data;
    return PlatformApp(
        title: "AppIRC",
        localizationsDelegates: [
          //app-specific localization
          EasylocaLizationDelegate(locale: data.locale, path: 'assets/langs'),
        ],
        supportedLocales: [Locale('en', 'US')],
        locale: data.savedLocale,
        android: (_) => MaterialAppData(theme: uiSkin.androidTheme),
        ios: (_) => CupertinoAppData(theme: uiSkin.iosTheme),
        home: SplashPage(_init));
  }
}

Future<ChatPreferences> _getSavedChatPreferencesOrNull(
    BuildContext context) async {
  var chatPreferencesBloc = Provider.of<ChatPreferencesBloc>(context);

  if (await chatPreferencesBloc.isSavedPreferenceExist) {
    return await chatPreferencesBloc.getValue(ChatPreferences.name());
  } else {
    return null;
  }
}

void _init(BuildContext context) {
  var preferencesService = Provider.of<PreferencesService>(context);

  preferencesService.init().then((_) {
    _createHomeWidget(context).then((nextPage) {
      Navigator.pushReplacement(
          context,
          platformPageRoute(
              builder: (context) => nextPage, maintainState: false));
    });
  });
}

Future<Widget> _initWhenBackendConnected(BuildContext context) async {
  var chatBloc = Provider.of<ChatBloc>(context);

  var isNetworksEmpty = await chatBloc.isNetworksEmpty;

  if (isNetworksEmpty) {
    return NewChatNetworkPage(createDefaultIRCNetworkPreferences(context));
  } else {
    return ChatPage();
  }
}

Future<Widget> _createHomeWidget(BuildContext context) async {
  var chatBloc = Provider.of<ChatBloc>(context);

  var backendConnected = await chatBloc.isBackendConnected;

  if (backendConnected) {
    return _initWhenBackendConnected(context);
  } else {
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    bool savedLoungePreferenceExist =
        await loungePreferencesBloc.isSavedPreferenceExist;

    if (savedLoungePreferenceExist) {
      backendConnected = await chatBloc.connectToBackend();

      if (backendConnected) {
        return _initWhenBackendConnected(context);
      } else {
        var loungePreferences = await loungePreferencesBloc
            .getValue(createDefaultLoungePreferences(context));
        return LoungeNewConnectionPage(loungePreferences);
      }
    } else {
      return LoungeNewConnectionPage(createDefaultLoungePreferences(context));
    }
  }
}

