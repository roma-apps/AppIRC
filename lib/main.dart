import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_new_connection_page.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_skin_bloc.dart';
import 'package:flutter_appirc/app/channel/list/unread_count/channel_list_unread_count_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_states_bloc.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_page.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/chat/deep_link/chat_deep_link_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_bloc.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_saver_bloc.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/upload/chat_upload_bloc.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/app/message/message_skin_bloc.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/message/special/message_special_skin_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_skin_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/state/network_states_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_app_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_button_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_channel_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_boolean_field_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_text_field_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_form_title_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_message_preview_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_message_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_message_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_message_special_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_network_list_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_popup_menu_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_search_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/app_irc_text_skin_bloc.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/skin/themes/day_app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/skin/themes/night_app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/splash/splash_page.dart';
import 'package:flutter_appirc/colored_nicknames/colored_nicknames_bloc.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
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

var _logger = MyLogger(logTag: "main.dart", enabled: true);

final String appTitle = "AppIRC";
final String relativePathToLangsFolder = 'assets/langs';
final List<Locale> supportedLocales = [Locale('en', 'US')];

Future main() async {
//  changeToCupertinoPlatformAware();

  WidgetsFlutterBinding.ensureInitialized();

  var preferencesService = PreferencesService();

  await preferencesService.init();
//           preferencesService.clear();

  var socketIOManager = SocketIOManager();
  var loungePreferencesBloc = LoungePreferencesBloc(preferencesService);

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
//  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // runZoned<Future<void>>(
  //   () async {
      runApp(
        EasyLocalization(
          supportedLocales: [
            Locale('en', 'US'),
          ],
          path: 'assets/langs',
          fallbackLocale: Locale('en', 'US'),
          child: Provider(
            providable: SocketIOManagerProvider(socketIOManager),
            child: Provider(
              child: Provider(
                providable: preferencesService,
                child: _InitAppIRCApp(),
              ),
              providable: loungePreferencesBloc,
            ),
          ),
        ),
      );
  //   },
  //   onError: Crashlytics.instance.recordError,
  // );
}

class _InitAppIRCApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InitAppIRCAppState();
}

class _InitAppIRCAppState extends State<_InitAppIRCApp> {
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
        return _buildAppForStartLoungePreferences(context);
      } else {
        if (_loungeBackendService == null) {
          return _buildAppForStartLoungePreferences(context);
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

    ChatActiveChannelBloc activeChannelBloc;
    Channel Function() currentChannelExtractor = () {
      return activeChannelBloc?.activeChannel;
    };

    await loungeBackendService.init(
        currentChannelExtractor: currentChannelExtractor,
        lastMessageRemoteIdExtractor: () async {
          var newestMessage = (await _database.regularMessagesDao
              .getNewestAllChannelsMessage());

          _logger.d(() => " newestMessage $newestMessage");

          return newestMessage?.messageRemoteId;
        });

    this._loungeBackendService = loungeBackendService;

    var chatPreferencesBloc = ChatPreferencesBloc(preferencesService);

    var networksListBloc = NetworkListBloc(
      loungeBackendService,
      nextNetworkIdGenerator: chatPreferencesBloc.getNextNetworkLocalId,
      nextChannelIdGenerator: chatPreferencesBloc.getNextChannelLocalId,
    );

    var messageCondensedBloc = MessageCondensedBloc();

    var networkStatesBloc =
        NetworkStatesBloc(loungeBackendService, networksListBloc);

    var _startPreferences =
        chatPreferencesBloc.getValue(defaultValue: ChatPreferences.empty);

    var connectionBloc = ChatConnectionBloc(loungeBackendService);

    var chatInitBloc = ChatInitBloc(loungeBackendService, connectionBloc,
        networksListBloc, _startPreferences);

    var chatPushesService =
        ChatPushesService(_pushesService, loungeBackendService, chatInitBloc);

    activeChannelBloc = ChatActiveChannelBloc(loungeBackendService,
        chatInitBloc, networksListBloc, preferencesService, chatPushesService);

    var channelsStatesBloc = ChannelStatesBloc(
        loungeBackendService, _database, networksListBloc, activeChannelBloc);

    var channelsBlocsBloc = ChannelBlocsBloc(loungeBackendService,
        chatPushesService, networksListBloc, channelsStatesBloc);
    var networksBlocsBloc = NetworkBlocsBloc(
        loungeBackendService,
        networksListBloc,
        networkStatesBloc,
        channelsStatesBloc,
        activeChannelBloc);

    var chatDeepLinkBloc = ChatDeepLinkBloc(loungeBackendService, chatInitBloc,
        networksListBloc, networksBlocsBloc, activeChannelBloc);

    var chatUploadBloc = ChatUploadBloc(loungeBackendService);

    var chatUnreadBloc = ChannelListUnreadCountBloc(channelsStatesBloc);

    var chatPreferencesSaverBloc = ChatPreferencesSaverBloc(
        loungeBackendService,
        networkStatesBloc,
        networksListBloc,
        chatPreferencesBloc,
        chatInitBloc);

    var messageManagerBloc =
        MessageManagerBloc(loungeBackendService, networksListBloc, _database);

    Disposable signOutListener;
    signOutListener = loungeBackendService.listenForSignOut(() async {
      await messageManagerBloc.clearAllMessages();

      chatPreferencesSaverBloc.reset();
      this._loungeBackendService.dispose();
      this._loungeBackendService = null;
      this._loungePreferences = LoungePreferences.empty;

      var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);
      loungePreferencesBloc.setValue(_loungePreferences);

      signOutListener.dispose();

      setState(() {});
    });
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
                              providable: messageCondensedBloc,
                              child: Provider(
                                providable: chatInitBloc,
                                child: Provider(
                                  providable: chatUnreadBloc,
                                  child: Provider(
                                    providable: chatPushesService,
                                    child: Provider(
                                      providable: chatUploadBloc,
                                      child: Provider(
                                        providable: messageManagerBloc,
                                        child: Provider(
                                          providable: chatPreferencesSaverBloc,
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
      ),
    );
  }

  Widget _buildAppForStartLoungePreferences(BuildContext context) {
    var settings = createDefaultLoungePreferences(context);
    var connectionBloc = LoungeConnectionBloc(
        Provider.of<SocketIOManagerProvider>(context).manager,
        settings.hostPreferences,
        settings.authPreferences);
    return Provider(
        providable: connectionBloc,
        child: Provider(
            providable: LoungeConnectionFormBloc(connectionBloc),
            child: _buildApp(NewLoungeConnectionPage())));
  }

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
          // todo: remove copy-paste
          supportedLocales: [
            Locale('en', 'US'),
          ],
          path: 'assets/langs',
          fallbackLocale: Locale('en', 'US'),
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

                var appIRCAppSkinBloc = AppIRCAppSkinBloc(appSkinTheme);

                // todo: rework to multi-provider
                return Provider(
                  providable: appIRCAppSkinBloc,
                  child: Provider<AppSkinBloc>(
                    providable: appIRCAppSkinBloc,
                    child: Provider<ChannelListSkinBloc>(
                      providable: AppIRCChannelListSkinBloc(appSkinTheme),
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
                                child: Provider<MessageListSkinBloc>(
                                  providable:
                                      AppIRCMessageListSkinBloc(appSkinTheme),
                                  child: Provider<MessageSkinBloc>(
                                    providable:
                                        AppIRCMessageSkinBloc(appSkinTheme),
                                    child: Provider<SearchSkinBloc>(
                                      providable:
                                          AppIRCMessageListSearchSkinBloc(
                                              appSkinTheme),
                                      child: Provider<RegularMessageSkinBloc>(
                                        providable:
                                            AppIRCRegularMessageSkinBloc(
                                                appSkinTheme),
                                        child: Provider<SpecialMessageSkinBloc>(
                                          providable:
                                              AppIRCSpecialMessageSkinBloc(
                                                  appSkinTheme),
                                          child:
                                              Provider<MessagePreviewSkinBloc>(
                                            providable:
                                                AppIRCMessagePreviewSkinBloc(),
                                            child:
                                                Provider<NetworkListSkinBloc>(
                                              providable:
                                                  AppIRCNetworkListSkinBloc(
                                                      appSkinTheme),
                                              child:
                                                  Provider<PopupMenuSkinBloc>(
                                                providable:
                                                    AppIRCPopupMenuSkinBloc(
                                                        appSkinTheme),
                                                child: Provider<TextSkinBloc>(
                                                  providable:
                                                      AppIRCTextSkinBloc(
                                                          appSkinTheme),
                                                  child:
                                                      Provider<ButtonSkinBloc>(
                                                    providable:
                                                        AppIRCButtonSkinBloc(
                                                            appSkinTheme),
                                                    child: Provider(
                                                      providable:
                                                          ColoredNicknamesBloc(
                                                              appSkinTheme
                                                                  .coloredNicknamesData),
                                                      child: _AppIrc(
                                                        appSkinTheme:
                                                            appSkinTheme,
                                                        child: child,
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
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class _AppIrc extends StatelessWidget {
  const _AppIrc({
    Key key,
    @required this.appSkinTheme,
    @required this.child,
  }) : super(key: key);

  final AppIRCSkinTheme appSkinTheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      material: (context, platform) => MaterialAppData(
        theme: appSkinTheme.androidThemeDataCreator(),
      ),
      cupertino: (context, platform) => CupertinoAppData(
        theme: appSkinTheme.iosThemeDataCreator(),
      ),
      home: child,
    );
  }
}

AppIRCSkinTheme _defaultSkinTheme() => DayAppSkinTheme();

List<AppIRCSkinTheme> _additionalSkinThemes() => [NightAppSkinTheme()];
