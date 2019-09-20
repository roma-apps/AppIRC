import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_page.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_page.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "Main", enabled: true);

Future main() async {
  var preferencesService = PreferencesService();
  var socketIOManager = SocketIOManager();

  var loungePreferencesBloc = LoungePreferencesBloc(preferencesService);
  runApp(EasyLocalization(
      child: Provider(
    providable: SocketIOManagerProvider(socketIOManager),
    child: Provider(
        child: Provider(providable: preferencesService, child: AppIRC()),
        providable: loungePreferencesBloc),
  )));
}

class AppIRC extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppIRCState();
}

class AppIRCState extends State<AppIRC> {
  bool isInitStarted = false;
  bool isInitSuccess = false;
  LoungeBackendService loungeBackendService;
  LoungeConnectionPreferences loungeConnectionPreferences;
  bool isChatBuildOneTime = false;

  @override
  Widget build(BuildContext context) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    if (!isInitSuccess) {
      if (!isInitStarted) {
        isInitStarted = true;
        Timer.run(() async {
          await preferencesService.init();
//           preferencesService.clear();

          loungePreferencesBloc
              .valueStream(defaultValue: LoungeConnectionPreferences.empty)
              .listen((newPreferences) {
            _onLoungeChanged(context, newPreferences);
          });
          isInitSuccess = true;
          setState(() {});
        });
      }

      return _buildApp(SplashPage());
    } else {
      if (loungeConnectionPreferences == null) {
        return _buildAppForStartLoungePreferences();
      } else {
        if (loungeBackendService == null) {
          return _buildAppForStartLoungePreferences();
        } else {
          var buildChat2 = buildChat(context, loungeBackendService, preferencesService, isChatBuildOneTime);
          isChatBuildOneTime = true;
          return buildChat2;
        }
      }
    }
  }

  void _onLoungeChanged(
      BuildContext context, LoungeConnectionPreferences newPreferences) async {
    if (newPreferences != null &&
        newPreferences != LoungeConnectionPreferences.empty &&
        newPreferences != loungeConnectionPreferences) {
      loungeConnectionPreferences = newPreferences;

      _logger.d(() => "_onLoungeChanged $newPreferences");

      var socketManagerProvider = Provider.of<SocketIOManagerProvider>(context);
      var loungeBackendService = LoungeBackendService(
          socketManagerProvider.manager, loungeConnectionPreferences);

      loungeBackendService.init().then((_) {
        this.loungeBackendService = loungeBackendService;
        isChatBuildOneTime = false;
        setState(() {});
      });
    }
  }

  Widget _buildAppForStartLoungePreferences() => _buildApp(
      NewLoungePreferencesPage(createDefaultLoungePreferences(context)));

  Widget buildChat(
      BuildContext context,
      LoungeBackendService loungeBackendService,
      PreferencesService preferencesService, bool isChatBuildOneTime) {
//    var loungeBackendService =
//    Provider.of<LoungeBackendService>(context);
//    var preferencesService =
//    Provider.of<PreferencesService>(context);

    _logger.d(() => "buildChat $isChatBuildOneTime");

    var chatPreferencesBloc = ChatPreferencesLoaderBloc(preferencesService);

    var networksListBloc = ChatNetworksListBloc(
      loungeBackendService,
      nextNetworkIdGenerator: chatPreferencesBloc.getNextNetworkLocalId,
      nextChannelIdGenerator: chatPreferencesBloc.getNextNetworkChannelLocalId,
    );

    var connectionBloc = ChatConnectionBloc(loungeBackendService);
    var networkStatesBloc =
        ChatNetworksStateBloc(loungeBackendService, networksListBloc);
    var channelsStatesBloc =
        ChatNetworkChannelsStateBloc(loungeBackendService, networksListBloc);

    var _startPreferences =
        chatPreferencesBloc.getValue(defaultValue: ChatPreferences.empty);

    var chatInitBloc =
        ChatInitBloc(loungeBackendService, connectionBloc, _startPreferences, isChatBuildOneTime);
    return Provider<LoungeBackendService>(
      providable: loungeBackendService,
      child: Provider<ChatInputOutputBackendService>(
        providable: loungeBackendService,
        child: Provider<ChatOutputBackendService>(
          providable: loungeBackendService,
          child: Provider<ChatInputBackendService>(
            providable: loungeBackendService,
            child: Provider(
              providable: chatPreferencesBloc,
              child: Provider(
                providable: connectionBloc,
                child: Provider(
                  providable: networksListBloc,
                  child: Provider(
                    providable: networkStatesBloc,
                    child: Provider(
                      providable: channelsStatesBloc,
                      child: Provider(
                        providable: chatInitBloc,
                        child: Provider(
                          providable: ChatPreferencesSaverBloc(
                              preferencesService,
                              networksListBloc,
                              chatInitBloc),
                          child: _buildApp(ChatPage()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApp(Widget child) {
    var preferencesService = Provider.of<PreferencesService>(context);

    var defaultUISkin = createDefaultUISkin();
    var appSkinBloc = AppSkinBloc(preferencesService, defaultUISkin);

    return EasyLocalization(
      child: StreamBuilder<UISkin>(
          stream: appSkinBloc.skinStream,
          initialData: defaultUISkin,
          builder: (context, snapshot) {
            var data = EasyLocalizationProvider.of(context).data;

            var uiSkin = snapshot.data;
            return Provider(
              providable: uiSkin,
              child: PlatformApp(
                  title: "AppIRC",
                  localizationsDelegates: [
                    //app-specific localization
                    EasylocaLizationDelegate(
                        locale: data.locale, path: 'assets/langs'),
                  ],
                  supportedLocales: [Locale('en', 'US')],
                  locale: data.savedLocale,
                  android: (_) => MaterialAppData(theme: uiSkin.androidTheme),
                  ios: (_) => CupertinoAppData(theme: uiSkin.iosTheme),
                  home: child),
            );
          }),
    );
  }
}

//class AppIRC2 extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    var preferencesService = Provider.of<PreferencesService>(context);
//    var loungePreferencesBloc = LoungePreferencesBloc(preferencesService);
//
//    var defaultUISkin = createDefaultUISkin();
//    var appSkinBloc = AppSkinBloc(preferencesService, defaultUISkin);
//    return Provider<PreferencesService>(
//        providable: preferencesService,
//        child: Provider<LoungePreferencesBloc>(
//          providable: loungePreferencesBloc,
//          child: StreamBuilder<LoungeConnectionPreferences>(
//              stream: loungePreferencesBloc.valueStream(
//                  defaultValue: LoungeConnectionPreferences.empty),
//              builder: (context, snapshot) {
//                var loungePreferences = snapshot.data;
//
//                _logger.d(() => "stream for $loungePreferences");
//
//                var loungeBackendService =
//                LoungeBackendService(socketIOManager, loungePreferences);
//
//                var data = EasyLocalizationProvider
//                    .of(context)
//                    .data;
//
//                return Provider<LoungeBackendService>(
//                  providable: loungeBackendService,
//                  child: Provider<ChatInputOutputBackendService>(
//                    providable: loungeBackendService,
//                    child: Provider<ChatOutputBackendService>(
//                      providable: loungeBackendService,
//                      child: Provider<ChatInputBackendService>(
//                        providable: loungeBackendService,
//                        child: Provider(
//                          providable: chatPreferencesBloc,
//                          child: Provider(
//                            providable: connectionBloc,
//                            child: Provider(
//                              providable: networksListBloc,
//                              child: Provider(
//                                providable: networkStatesBloc,
//                                child: Provider(
//                                  providable: channelsStatesBloc,
//                                  child: Provider(
//                                      providable: ChatPreferencesSaverBloc(
//                                          preferencesService, networksListBloc),
//                                      child: StreamBuilder<UISkin>(
//                                          stream: appSkinBloc.skinStream,
//                                          initialData: defaultUISkin,
//                                          builder: (context, snapshot) {
//                                            var uiSkin = snapshot.data;
//                                            return Provider(
//                                              providable: uiSkin,
//                                              child: PlatformApp(
//                                                  title: "AppIRC",
//                                                  localizationsDelegates: [
//                                                    //app-specific localization
//                                                    EasylocaLizationDelegate(
//                                                        locale: data.locale,
//                                                        path: 'assets/langs'),
//                                                  ],
//                                                  supportedLocales: [
//                                                    Locale('en', 'US')
//                                                  ],
//                                                  locale: data.savedLocale,
//                                                  android: (_) =>
//                                                      MaterialAppData(
//                                                          theme: uiSkin
//                                                              .androidTheme),
//                                                  ios: (_) =>
//                                                      CupertinoAppData(
//                                                          theme: uiSkin
//                                                              .iosTheme),
//                                                  home: buildChatApp(
//                                                      loungePreferences,
//                                                      context)),
//                                            );
//                                          })),
//                                ),
//                              ),
//                            ),
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
//                );
//              }),
//        ));
//  }
////
////  Widget buildChatApp(LoungeConnectionPreferences loungePreferences,
////      BuildContext context) {
////    var isHaveSavedPreferences =
////        loungePreferences != LoungeConnectionPreferences.empty;
////    if (!isHaveSavedPreferences) {
////      return NewLoungePreferencesPage(createDefaultLoungePreferences(context));
////    } else {
////      return SplashPage((context) async {
////        var backendService = Provider.of<LoungeBackendService>(context);
////        await backendService.init();
////
////        var chatPreferencesLoaderBloc =
////        Provider.of<ChatPreferencesLoaderBloc>(context);
////
////        var _startPreferences = await chatPreferencesLoaderBloc.getValue(
////            defaultValue: ChatPreferences.empty);
////
////        await chatPreferencesLoaderBloc.init();
////
////        await Provider.of<ChatPreferencesSaverBloc>(context).init();
////        await Provider.of<ChatNetworksListBloc>(context).init();
////
////        var chatConnectionBloc = Provider.of<ChatConnectionBloc>(context);
////        await chatConnectionBloc.init();
////        await Provider.of<ChatNetworksStateBloc>(context).init();
////        await Provider.of<ChatNetworkChannelsStateBloc>(context).init();
////
////        var chatInitBloc =
////        ChatInitBloc(backendService, chatConnectionBloc, _startPreferences);
////
//////        await chatInitBloc.init();
////
////        Navigator.pushReplacement(
////            context,
////            platformPageRoute(
////                maintainState: false,
////                builder: (_) =>
////                    Provider(providable: chatInitBloc, child: ChatPage())));
////      });
////    }
////  }
//}
