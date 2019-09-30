import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_page.dart';
import 'package:flutter_appirc/app/channel/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_messages_saver_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_page.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_saver_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/message/messages_colored_nicknames_bloc.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/message/messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_app_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_button_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/skin/themes/night_app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/form/form_skin_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'app/skin/app_irc_channels_list_skin_bloc.dart';
import 'app/skin/app_irc_chat_input_message_skin_bloc.dart';
import 'app/skin/themes/day_app_irc_skin_theme.dart';

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

  ChatDatabase database;

  Widget createdWidget;

  LoungeConnectionPreferences loungeConnectionPreferences;

  @override
  Widget build(BuildContext context) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    if (!isInitSuccess) {
      if (!isInitStarted) {
        isInitStarted = true;
        Timer.run(() async {
          database = await $FloorChatDatabase
              .databaseBuilder('flutter_database.db')
              .build();

          database.regularMessagesDao.deleteAllRegularMessages();
          database.specialMessagesDao.deleteAllSpecialMessages();

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

      return _buildApp(SplashPage(), isPreferencesReady: false);
    } else {
      if (loungeConnectionPreferences == null) {
        return _buildAppForStartLoungePreferences();
      } else {
        if (loungeBackendService == null) {
          return _buildAppForStartLoungePreferences();
        } else {
          return createdWidget;
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

      var preferencesService = Provider.of<PreferencesService>(context);
      var socketManagerProvider = Provider.of<SocketIOManagerProvider>(context);
      var loungeBackendService = LoungeBackendService(
          socketManagerProvider.manager, loungeConnectionPreferences);

      loungeBackendService.init().then((_) {
        this.loungeBackendService = loungeBackendService;

        var chatPreferencesBloc = ChatPreferencesBloc(preferencesService);

        var networksListBloc = ChatNetworksListBloc(
          loungeBackendService,
          nextNetworkIdGenerator: chatPreferencesBloc.getNextNetworkLocalId,
          nextChannelIdGenerator:
              chatPreferencesBloc.getNextNetworkChannelLocalId,
        );

        var connectionBloc = ChatConnectionBloc(loungeBackendService);
        var networkStatesBloc =
            ChatNetworksStateBloc(loungeBackendService, networksListBloc);

        var _startPreferences =
            chatPreferencesBloc.getValue(defaultValue: ChatPreferences.empty);

        var chatInitBloc = ChatInitBloc(
            loungeBackendService, connectionBloc, _startPreferences);

        var activeChannelBloc = ChatActiveChannelBloc(loungeBackendService,
            chatInitBloc, networksListBloc, preferencesService);

        var channelsStatesBloc = ChatNetworkChannelsStateBloc(
            loungeBackendService, networksListBloc, activeChannelBloc);

        createdWidget = Provider(
          providable: ChatDatabaseProvider(database),
          child: Provider<ChatBackendService>(
            providable: loungeBackendService,
            child: Provider<LoungeBackendService>(
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
                                providable: activeChannelBloc,
                                child: Provider(
                                  providable: chatInitBloc,
                                  child: Provider(
                                    providable: NetworkChannelMessagesSaverBloc(
                                        loungeBackendService,
                                        networksListBloc,
                                        database),
                                    child: Provider(
                                      providable: ChatPreferencesSaverBloc(
                                          networksListBloc,
                                          networkStatesBloc,
                                          chatPreferencesBloc,
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
                ),
              ),
            ),
          ),
        );

        setState(() {});
      });
    }
  }

  Widget _buildAppForStartLoungePreferences() => _buildApp(
      NewLoungePreferencesPage(createDefaultLoungePreferences(context)));

  Widget _buildApp(Widget child, {bool isPreferencesReady = true}) {
    var preferencesService = Provider.of<PreferencesService>(context);

    var defaultSkinTheme = _defaultSkinTheme();
    List<AppIRCSkinTheme> _allSkinThemes = [defaultSkinTheme];
    _allSkinThemes.addAll(_additionalSkinThemes());
    var appSkinPreferenceBloc = AppSkinPreferenceBloc<AppIRCSkinTheme>(
        preferencesService, _allSkinThemes, defaultSkinTheme);

    return Provider(
      providable: appSkinPreferenceBloc,
      child: Provider<AppSkinPreferenceBloc>(
        providable: appSkinPreferenceBloc,
        child: EasyLocalization(
          child: StreamBuilder<AppIRCSkinTheme>(
              stream: isPreferencesReady
                  ? appSkinPreferenceBloc.appSkinStream
                  : BehaviorSubject<AppIRCSkinTheme>(
                      seedValue: defaultSkinTheme),
              initialData: isPreferencesReady
                  ? appSkinPreferenceBloc.currentAppSkinTheme
                  : defaultSkinTheme,
              builder: (context, snapshot) {
                AppIRCSkinTheme appSkinTheme = snapshot.data;

                var data = EasyLocalizationProvider.of(context).data;

                var appIRCAppSkinBloc = AppIRCAppSkinBloc(appSkinTheme);
                return Provider(
                  providable: appIRCAppSkinBloc,
                  child: Provider<AppSkinBloc>(
                    providable: appIRCAppSkinBloc,
                    child: Provider<ChannelsListSkinBloc>(
                      providable: AppIRCChannelsListSkinBloc(appSkinTheme),
                      child: Provider<ChatAppBarSkinBloc>(
                        providable: AppIRCChatAppBarSkinBloc(appSkinTheme),
                        child: Provider<ChatInputMessageSkinBloc>(
                          providable:
                              AppIRCChatInputMessageSkinBloc(appSkinTheme),
                          child: Provider<FormSkinBloc>(
                            providable: AppIRCFormSkinBloc(appSkinTheme),
                            child: Provider<MessagesRegularSkinBloc>(
                              providable:
                                  AppIRCMessagesRegularSkinBloc(appSkinTheme),
                              child: Provider<MessagesSpecialSkinBloc>(
                                providable:
                                    AppIRCMessagesSpecialSkinBloc(appSkinTheme),
                                child: Provider<NetworkListSkinBloc>(
                                  providable:
                                      AppIRCNetworkListSkinBloc(appSkinTheme),
                                  child: Provider<ButtonSkinBloc>(
                                    providable:
                                        AppIRCButtonSkinBloc(appSkinTheme),
                                    child: Provider(
                                      providable: MessagesColoredNicknamesBloc(
                                          appSkinTheme.coloredNicknamesData),
                                      child: PlatformApp(
                                          title: "AppIRC",
                                          localizationsDelegates: [
                                            //app-specific localization
                                            EasylocaLizationDelegate(
                                                locale: data.locale,
                                                path: 'assets/langs'),
                                          ],
                                          supportedLocales: [
                                            Locale('en', 'US')
                                          ],
                                          locale: data.savedLocale,
                                          android: (_) => MaterialAppData(
                                              theme: appSkinTheme
                                                  .androidThemeDataCreator()),
                                          ios: (_) => CupertinoAppData(
                                              theme: appSkinTheme
                                                  .iosThemeDataCreator()),
                                          home: child),
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
              }),
        ),
      ),
    );
  }
}

AppIRCSkinTheme _defaultSkinTheme() => DayAppSkinTheme();

List<AppIRCSkinTheme> _additionalSkinThemes() => [NightAppSkinTheme()];
