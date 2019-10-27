import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/page/lounge_new_preferences_page.dart';
import 'package:flutter_appirc/app/channel/list/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_page.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_saver_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_saver_bloc.dart';
import 'package:flutter_appirc/app/chat/state/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/state/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/state/chat_unread_bloc.dart';
import 'package:flutter_appirc/app/chat/upload/chat_upload_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/deep_link/chat_deep_link_bloc.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/message/special/messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/list/networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/push_notifications/chat_pushes_service.dart';
import 'package:flutter_appirc/app/skin/app_irc_app_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_button_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_boolean_field_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_text_field_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_title_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_messages_special_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_networks_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_popup_menu_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_text_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/skin/themes/night_app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/form/field/boolean/form_boolean_field_skin_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_skin_bloc.dart';
import 'package:flutter_appirc/form/form_title_skin_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/pushes/push_service.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/popup_menu_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'app/skin/app_irc_channels_list_skin_bloc.dart';
import 'app/skin/app_irc_chat_input_message_skin_bloc.dart';
import 'app/skin/themes/day_app_irc_skin_theme.dart';

var _logger = MyLogger(logTag: "main.dart", enabled: true);

final String appTitle = "AppIRC";
final String relativePathToLangsFolder = 'assets/langs';
final List<Locale> supportedLocales = [Locale('en', 'US')];

Future main() async {
//  changeToCupertinoPlatformAware();

  var preferencesService = PreferencesService();

  await preferencesService.init();
//           preferencesService.clear();

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
  LoungeBackendService _loungeBackendService;

  ChatDatabase _database;

  Widget _createdWidget;

  LoungePreferences _loungePreferences;

  PushesService _pushesService = PushesService();

  @override
  Widget build(BuildContext context) {
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    if (!isInitSuccess) {
      if (!isInitStarted) {
        isInitStarted = true;
        Timer.run(() async {
          await _init(context, loungePreferencesBloc);
          setState(() {});
        });
      }

      return _buildApp(SplashPage());
    } else {
      if (_loungePreferences == null) {
        return _buildAppForStartLoungePreferences();
      } else {
        if (_loungeBackendService == null) {
          return _buildAppForStartLoungePreferences();
        } else {
          return _createdWidget;
        }
      }
    }
  }

  Future _init(
      BuildContext context, LoungePreferencesBloc loungePreferencesBloc) async {
    _database =
        await $FloorChatDatabase.databaseBuilder('flutter_database.db').build();

    _database.regularMessagesDao.deleteAllRegularMessages();
    _database.specialMessagesDao.deleteAllSpecialMessages();

    await _pushesService.init();
    await _pushesService.askPermissions();
    await _pushesService.configure();

    loungePreferencesBloc
        .valueStream(defaultValue: LoungePreferences.empty)
        .listen((newPreferences) {
      _onLoungeChanged(context, newPreferences);
    });
    isInitSuccess = true;
  }

  void _onLoungeChanged(
      BuildContext context, LoungePreferences newPreferences) async {
    if (newPreferences != null &&
        newPreferences != LoungePreferences.empty &&
        newPreferences != _loungePreferences) {
      _loungePreferences = newPreferences;

      await _recreateChatApp(newPreferences, context);

      setState(() {});
    }
  }

  Future _recreateChatApp(
      LoungePreferences newPreferences, BuildContext context) async {
    _logger.d(() => "_onLoungeChanged $newPreferences");

    var preferencesService = Provider.of<PreferencesService>(context);
    var socketManagerProvider = Provider.of<SocketIOManagerProvider>(context);
    var loungeBackendService =
        LoungeBackendService(socketManagerProvider.manager, _loungePreferences);

    await loungeBackendService.init();

    loungeBackendService.listenForSignOut(() {
      loungeBackendService.dispose();
      this._loungeBackendService = null;
      this._loungePreferences.authPreferences = null;

      var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);
      loungePreferencesBloc.setValue(LoungePreferences.empty);
      setState(() {});
    });

    var chatPushesService =
        ChatPushesService(_pushesService, loungeBackendService);

    this._loungeBackendService = loungeBackendService;

    var chatPreferencesBloc = ChatPreferencesBloc(preferencesService);

    var networksListBloc = ChatNetworksListBloc(
      loungeBackendService,
      nextNetworkIdGenerator: chatPreferencesBloc.getNextNetworkLocalId,
      nextChannelIdGenerator: chatPreferencesBloc.getNextNetworkChannelLocalId,
    );

    var connectionBloc = ChatConnectionBloc(loungeBackendService);
    var networkStatesBloc =
        ChatNetworksStateBloc(loungeBackendService, networksListBloc);

    var _startPreferences =
        chatPreferencesBloc.getValue(defaultValue: ChatPreferences.empty);

    var chatInitBloc = ChatInitBloc(loungeBackendService, connectionBloc,
        networksListBloc, _startPreferences);

    var activeChannelBloc = ChatActiveChannelBloc(loungeBackendService,
        chatInitBloc, networksListBloc, preferencesService, chatPushesService);

    var channelsStatesBloc = ChatNetworkChannelsStateBloc(
        loungeBackendService, networksListBloc, activeChannelBloc);

    var channelsBlocsBloc = ChatNetworkChannelsBlocsBloc(
        loungeBackendService, networksListBloc, channelsStatesBloc);
    var networksBlocsBloc = ChatNetworksBlocsBloc(
        loungeBackendService,
        networksListBloc,
        networkStatesBloc,
        channelsStatesBloc,
        activeChannelBloc);

    var chatDeepLinkBloc = ChatDeepLinkBloc(loungeBackendService, chatInitBloc,
        networksListBloc, networksBlocsBloc, activeChannelBloc);

    var chatUploadBloc = ChatUploadBloc(loungeBackendService);

    var chatUnreadBloc = ChatUnreadBloc(channelsStatesBloc);
    _createdWidget = Provider(
      providable: chatDeepLinkBloc,
      child: Provider(
        providable: ChatDatabaseProvider(_database),
        child: Provider<ChatBackendService>(
          providable: loungeBackendService,
          child: Provider<LoungeBackendService>(
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
                        providable: networksBlocsBloc,
                        child: Provider(
                          providable: channelsBlocsBloc,
                          child: Provider(
                            providable: activeChannelBloc,
                            child: Provider(
                              providable: chatInitBloc,
                              child: Provider(
                                providable: chatUnreadBloc,
                                child: Provider(
                                  providable: chatPushesService,
                                  child: Provider(
                                    providable: chatUploadBloc,
                                    child: Provider(
                                      providable:
                                          NetworkChannelMessagesSaverBloc(
                                              loungeBackendService,
                                              networksListBloc,
                                              _database),
                                      child: Provider(
                                        providable: ChatPreferencesSaverBloc(
                                            loungeBackendService,
                                            networkStatesBloc,
                                            networksListBloc,
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
          ),
        ),
      ),
    );
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
                          child: Provider<FormTitleSkinBloc>(
                            providable: AppIRCFormTitleSkinBloc(appSkinTheme),
                            child: Provider<FormBooleanFieldSkinBloc>(
                              providable:
                                  AppIRCFormBooleanFieldSkinBloc(appSkinTheme),
                              child: Provider<FormTextFieldSkinBloc>(
                                providable:
                                    AppIRCFormTextFieldSkinBloc(appSkinTheme),
                                child: Provider<MessagesRegularSkinBloc>(
                                  providable: AppIRCMessagesRegularSkinBloc(
                                      appSkinTheme),
                                  child: Provider<MessagesSpecialSkinBloc>(
                                    providable: AppIRCMessagesSpecialSkinBloc(
                                        appSkinTheme),
                                    child: Provider<NetworkListSkinBloc>(
                                      providable: AppIRCNetworkListSkinBloc(
                                          appSkinTheme),
                                      child: Provider<PopupMenuSkinBloc>(
                                        providable: AppIRCPopupMenuSkinBloc(
                                            appSkinTheme),
                                        child: Provider<TextSkinBloc>(
                                          providable:
                                              AppIRCTextSkinBloc(appSkinTheme),
                                          child: Provider<ButtonSkinBloc>(
                                            providable: AppIRCButtonSkinBloc(
                                                appSkinTheme),
                                            child: Provider(
                                              providable: ColoredNicknamesBloc(
                                                  appSkinTheme
                                                      .coloredNicknamesData),
                                              child: PlatformApp(
                                                  title: appTitle,
                                                  localizationsDelegates: [
                                                    //app-specific localization
                                                    EasylocaLizationDelegate(
                                                        locale: data.locale,
                                                        path: relativePathToLangsFolder),
                                                  ],
                                                  supportedLocales:
                                                      supportedLocales,
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
