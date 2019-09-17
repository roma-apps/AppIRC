import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_page.dart';
import 'package:flutter_appirc/app/chat/chat_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_defaults.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/irc_chat_page.dart';
import 'package:flutter_appirc/app/networks/irc_network_preferences_page.dart';
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

Future main() async {
  var preferencesService = PreferencesService();

  await preferencesService.init();
  runApp(EasyLocalization(
      child: Provider(bloc: preferencesService, child: AppIRC())));
}

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var loungePreferencesBloc = LoungePreferencesBloc(preferencesService);
    return Provider<PreferencesService>(
      bloc: preferencesService,
      child: Provider<LoungePreferencesBloc>(
        bloc: loungePreferencesBloc,
        child: StreamBuilder<LoungePreferences>(
            stream: loungePreferencesBloc
                .valueStream(createDefaultLoungePreferences(context)),
            builder: (context, snapshot) => buildChatApp(snapshot, context)),
      ),
    );
  }

  Widget buildChatApp(
      AsyncSnapshot<LoungePreferences> snapshot, BuildContext context) {
    var loungePreferences = snapshot.data;
    var preferencesService = Provider.of<PreferencesService>(context);
    var loungeBackendService =
        LoungeBackendService(socketIOManager, loungePreferences);
    var chatPreferencesBloc = ChatPreferencesLoaderBloc(preferencesService);
    var appSkinBloc = AppSkinBloc(preferencesService, createDefaultUISkin());
    var chatBloc = ChatBloc(
      loungeBackendService,
      () async => await _getSavedChatPreferencesOrNull(context),
      chatPreferencesBloc.getNextNetworkLocalId,
      chatPreferencesBloc.getNextNetworkChannelLocalId,
    );
    return Provider<LoungeBackendService>(
      bloc: loungeBackendService,
      child: Provider<ChatBackendService>(
        bloc: loungeBackendService,
        child: Provider(
          bloc: loungeBackendService.lounge,
          child: Provider(
            bloc: chatPreferencesBloc,
            child: Provider<ChatBloc>(
              bloc: chatBloc,
              child: Provider(
                bloc: ChatPreferencesSaverBloc(preferencesService, chatBloc),
                child: Provider<AppSkinBloc>(
                  bloc: appSkinBloc,
                  child: StreamBuilder<UISkin>(
                      stream: appSkinBloc.skinStream,
                      builder: (context, snapshot) {
                        var uiSkin = snapshot.data;
                        if (uiSkin == null) {
                          uiSkin = createDefaultUISkin();
                        }
                        return buildApp(context, uiSkin);
                      }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildApp(BuildContext context, UISkin uiSkin) {
    var data = EasyLocalizationProvider.of(context).data;
    return Provider(
      bloc: uiSkin,
      child: PlatformApp(
          title: "AppIRC",
          localizationsDelegates: [
            //app-specific localization
            EasylocaLizationDelegate(locale: data.locale, path: 'assets/langs'),
          ],
          supportedLocales: [Locale('en', 'US')],
          locale: data.savedLocale,
          android: (_) => MaterialAppData(theme: uiSkin.androidTheme),
          ios: (_) => CupertinoAppData(theme: uiSkin.iosTheme),
          home: SplashPage(_init)),
    );
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

void _init(BuildContext context) async {
  try {
    var homeWidget = await _createHomeWidget(context);

    Navigator.pushReplacement(
        context, platformPageRoute(builder: (_) => homeWidget));
  } on Exception catch (e) {
    _logger.e(() => "Error during loading $e");
  }
}

Future<Widget> _initWhenBackendConnected(BuildContext context) async {
  var chatBloc = Provider.of<ChatBloc>(context);

  var isNetworksEmpty = await chatBloc.isNetworksEmpty;

  if (isNetworksEmpty) {
    return NewChatNetworkPage(createDefaultIRCNetworkPreferences(context), () {
      Navigator.pushReplacement(
          context, platformPageRoute(builder: (_) => ChatPage()));
    });
  } else {
    return ChatPage();
  }
}

Future<Widget> _createHomeWidget(BuildContext context) async {
  var chatBloc = Provider.of<ChatBloc>(context);

  var backendConnected = chatBloc.isConnected;

  if (backendConnected) {
    return _initWhenBackendConnected(context);
  } else {
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);
    _logger.d(() => "before savedLoungePreferenceExist");
    bool savedLoungePreferenceExist =
        await loungePreferencesBloc.isSavedPreferenceExist;
    _logger
        .d(() => "savedLoungePreferenceExist => $savedLoungePreferenceExist");

    if (savedLoungePreferenceExist) {
      _logger.d(() => "before backendConnected");
      backendConnected = await chatBloc.connectToBackend();
      _logger.d(() => "backendConnected => $backendConnected");
      if (backendConnected) {
        return _initWhenBackendConnected(context);
      } else {
        var loungePreferences = await loungePreferencesBloc
            .getValue(createDefaultLoungePreferences(context));
        return NewLoungePreferencesPage(loungePreferences);
      }
    } else {
      return NewLoungePreferencesPage(createDefaultLoungePreferences(context));
    }
  }
}
