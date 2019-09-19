import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_page.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_page.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var socketIOManager = SocketIOManager();

Future main() async {
  var preferencesService = PreferencesService();

  await preferencesService.init();
  runApp(EasyLocalization(
      child: Provider(providable: preferencesService, child: AppIRC())));
}

class AppIRC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var loungePreferencesBloc = LoungePreferencesBloc(preferencesService);

    var defaultUISkin = createDefaultUISkin();
    var appSkinBloc = AppSkinBloc(preferencesService, defaultUISkin);
    return Provider<PreferencesService>(
        providable: preferencesService,
        child: Provider<LoungePreferencesBloc>(
          providable: loungePreferencesBloc,
          child: StreamBuilder<LoungeConnectionPreferences>(
              stream: loungePreferencesBloc.valueStream(
                  defaultValue: LoungeConnectionPreferences.empty),
              initialData: LoungeConnectionPreferences.empty,
              builder: (context, snapshot) {
                var loungePreferences = snapshot.data;

                var data = EasyLocalizationProvider.of(context).data;

                return StreamBuilder<UISkin>(
                    stream: appSkinBloc.skinStream,
                    initialData: defaultUISkin,
                    builder: (context, snapshot) {
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
                            android: (_) =>
                                MaterialAppData(theme: uiSkin.androidTheme),
                            ios: (_) =>
                                CupertinoAppData(theme: uiSkin.iosTheme),
                            home: buildChatApp(loungePreferences, context)),
                      );
                    });
              }),
        ));
  }

  Widget buildChatApp(
      LoungeConnectionPreferences loungePreferences, BuildContext context) {
    var isHaveSavedPreferences =
        loungePreferences == LoungeConnectionPreferences.empty;
    if (isHaveSavedPreferences) {
      return NewLoungePreferencesPage(createDefaultLoungePreferences(context));
    } else {
      var loungeBackendService =
          LoungeBackendService(socketIOManager, loungePreferences);

      return SplashPage((context) async {
        await loungeBackendService.init();

        var preferencesService = Provider.of<PreferencesService>(context);

        var chatPreferencesBloc = ChatPreferencesLoaderBloc(preferencesService);

        var networksListBloc = ChatNetworksListBloc(
          loungeBackendService,
          nextNetworkIdGenerator: chatPreferencesBloc.getNextNetworkLocalId,
          nextChannelIdGenerator:
              chatPreferencesBloc.getNextNetworkChannelLocalId,
        );

        var networkStatesBloc = ChatNetworksStateBloc(loungeBackendService, networksListBloc);
        var channelsStatesBloc = ChatNetworkChannelsStateBloc(loungeBackendService, networksListBloc);


        Navigator.pushReplacement(
            context,
            platformPageRoute(
                builder: (_) => Provider<LoungeBackendService>(
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
                                providable: networksListBloc,
                                child: Provider(
                                  providable: networkStatesBloc,
                                  child: Provider(
                                    providable: channelsStatesBloc,
                                    child: Provider(
                                        providable: ChatPreferencesSaverBloc(
                                            preferencesService, networksListBloc),
                                        child: ChatPage()),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )));
      });
    }
  }
}