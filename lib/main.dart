import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_new_connection_page.dart';
import 'package:flutter_appirc/app/chat/chat_page.dart';
import 'package:flutter_appirc/app/context/app_context_bloc.dart';
import 'package:flutter_appirc/app/context/app_context_bloc_impl.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/init/init_bloc.dart';
import 'package:flutter_appirc/app/init/init_bloc_impl.dart';
import 'package:flutter_appirc/app/instance/current/context/current_auth_instance_context_bloc_impl.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_bloc.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_proxy_provider.dart';
import 'package:flutter_appirc/app/ui/theme/current/current_appirc_ui_theme_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/dark/dark_appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/ui/theme/light/light_appirc_ui_theme_model.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_model.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/disposable/disposable_provider.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/localization/localization_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/socketio/socket_io_service.dart';
import 'package:flutter_appirc/ui/theme/system/brightness/ui_theme_system_brightness_handler_widget.dart';
import 'package:flutter_appirc/ui/theme/ui_theme_proxy_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

final _logger = Logger("main.dart");

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

CurrentAuthInstanceContextBloc currentInstanceContextBloc;

void main() async {
  // debugRepaintRainbowEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.

  await Firebase.initializeApp();

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runNotInitializedSplashApp();

  IInitBloc initBloc = InitBloc();
  unawaited(initBloc.performAsyncInit());

  initBloc.initLoadingStateStream.listen(
    (newState) async {
      _logger.fine(() => "appContextBloc.initLoadingStateStream.newState "
          "$newState");

      if (newState == AsyncInitLoadingState.finished) {
        var currentInstanceBloc =
            initBloc.appContextBloc.get<ICurrentAuthInstanceBloc>();

        currentInstanceBloc.currentInstanceStream
            .distinct()
            .listen((currentInstance) {
          runInitializedApp(
            appContextBloc: initBloc.appContextBloc,
            currentInstance: currentInstance,
          );
        });
      } else if (newState == AsyncInitLoadingState.failed) {
        runInitFailedApp();
      }
    },
  );
}

void runInitializedApp({
  @required AppContextBloc appContextBloc,
  @required LoungePreferences currentInstance,
}) async {
  _logger.finest(() => "runInitializedApp $runInitializedApp");
  if (currentInstance != null) {
    await runInitializedCurrentInstanceApp(
      appContextBloc: appContextBloc,
      currentInstance: currentInstance,
    );
  } else {
    runInitializedLoginApp(appContextBloc);
  }
}

void runInitializedLoginApp(AppContextBloc appContextBloc) {
  runApp(
    appContextBloc.provideContextToChild(
      child: DisposableProvider(
        create: (context) {
          var settings = createDefaultLoungePreferences();
          return LoungeConnectionBloc(
            SocketIOService.of(context, listen: false),
            settings.hostPreferences,
            settings.authPreferences,
          );
        },
        child: DisposableProxyProvider<LoungeConnectionBloc,
            LoungeConnectionFormBloc>(
          update: (context, value, previous) => LoungeConnectionFormBloc(
            value,
          ),
          child: AppIrcApp(
            instanceInitialized: true,
            child: const NewLoungeConnectionPage(),
          ),
        ),
      ),
    ),
  );
}

Future runInitializedCurrentInstanceApp({
  @required AppContextBloc appContextBloc,
  @required LoungePreferences currentInstance,
}) async {
  runInitializedSplashApp(
    appContextBloc: appContextBloc,
  );
  await currentInstanceContextBloc?.dispose();

  currentInstanceContextBloc = CurrentAuthInstanceContextBloc(
    currentInstance: currentInstance,
    appContextBloc: appContextBloc,
  );
  await currentInstanceContextBloc.performAsyncInit();
  _logger.finest(
      () => "buildCurrentInstanceApp CurrentInstanceContextLoadingPage");

  runApp(
    appContextBloc.provideContextToChild(
      child: currentInstanceContextBloc.provideContextToChild(
        child: AppIrcApp(
          instanceInitialized: true,
          child: const ChatPage(),
        ),
      ),
    ),
  );
}

void runNotInitializedSplashApp() {
  runApp(
    PlatformProvider(
      builder: (context) => PlatformApp(
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    ),
  );
}

void runInitFailedApp() {
  runApp(
    PlatformProvider(
      builder: (context) => PlatformApp(
        localizationsDelegates: [
          S.delegate,
        ],
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Builder(
                builder: (context) {
                  return Text(
                    S.of(context).app_init_fail,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _logger.severe(() => "failed to init App");
}

class AppIrcApp extends StatelessWidget {
  final Widget child;
  final bool instanceInitialized;

  AppIrcApp({
    @required this.child,
    @required this.instanceInitialized,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    var currentAppIrcUiThemeBloc =
        ICurrentAppIrcUiThemeBloc.of(context, listen: false);

    var localizationSettingsBloc =
        ILocalizationSettingsBloc.of(context, listen: false);

    return UiThemeSystemBrightnessHandlerWidget(
      child: StreamBuilder<IAppIrcUiTheme>(
        stream: currentAppIrcUiThemeBloc.adaptiveBrightnessCurrentThemeStream,
        builder: (context, snapshot) {
          var currentTheme = snapshot.data;

          var themeMode = currentTheme == null
              ? ThemeMode.system
              : currentTheme == darkAppIrcUiTheme
                  ? ThemeMode.dark
                  : ThemeMode.light;

          _logger.finest(() => "currentTheme $currentTheme "
              "themeMode $themeMode");

          return provideCurrentTheme(
            currentTheme: currentTheme ?? lightAppIrcUiTheme,
            child: StreamBuilder<LocalizationLocale>(
              stream: localizationSettingsBloc.localizationLocaleStream,
              builder: (context, snapshot) {
                var localizationLocale = snapshot.data;

                Locale locale;
                if (localizationLocale != null) {
                  locale = Locale.fromSubtags(
                    languageCode: localizationLocale.languageCode,
                    countryCode: localizationLocale.countryCode,
                    scriptCode: localizationLocale.scriptCode,
                  );
                }
                _logger.finest(() => "locale $locale");
                return PlatformProvider(
                  builder: (context) => PlatformApp(
                    // checkerboardRasterCacheImages: true,
                    // checkerboardOffscreenLayers: true,
                    debugShowCheckedModeBanner: false,
                    title: "AppIRC",
                    localizationsDelegates: [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    locale: locale,
                    material: (context, platform) => MaterialAppData(
                      theme: (currentTheme ?? lightAppIrcUiTheme).themeData,
                      darkTheme: darkAppIrcUiTheme.themeData,
                      themeMode: themeMode,
                    ),
                    cupertino: (context, platform) => CupertinoAppData(
                      theme: MaterialBasedCupertinoThemeData(
                        materialTheme:
                            (currentTheme ?? lightAppIrcUiTheme).themeData,
                      ),
                    ),
                    initialRoute: "/",
                    home: child,
                    navigatorKey: navigatorKey,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget provideCurrentTheme({
    @required Widget child,
    @required IAppIrcUiTheme currentTheme,
  }) =>
      Provider<IAppIrcUiTheme>.value(
        value: currentTheme,
        child: AppIrcUiThemeProxyProvider(
          child: UiThemeProxyProvider(
            child: DisposableProvider<ColoredNicknamesBloc>(
              create: (context) =>
                  ColoredNicknamesBloc(currentTheme.nicknameColorsData),
              child: child,
            ),
          ),
        ),
      );
}

void runInitializedSplashApp({
  @required AppContextBloc appContextBloc,
}) {
  runApp(
    appContextBloc.provideContextToChild(
      child: AppIrcApp(
        instanceInitialized: false,
        child: Provider<IAppContextBloc>.value(
          value: appContextBloc,
          child: const SplashPage(),
        ),
      ),
    ),
  );
}
