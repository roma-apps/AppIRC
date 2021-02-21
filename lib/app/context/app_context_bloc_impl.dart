import 'package:flutter_appirc/app/chat/db/chat_database_service.dart';
import 'package:flutter_appirc/app/context/app_context_bloc.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc_impl.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_local_preference_bloc.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_local_preference_bloc_impl.dart';
import 'package:flutter_appirc/app/localization/settings/local_preference/localization_settings_local_preferences_bloc.dart';
import 'package:flutter_appirc/app/localization/settings/local_preference/localization_settings_local_preferences_bloc_impl.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_bloc.dart';
import 'package:flutter_appirc/app/localization/settings/localization_settings_bloc_impl.dart';
import 'package:flutter_appirc/app/logging/logging_service.dart';
import 'package:flutter_appirc/app/logging/logging_service_impl.dart';
import 'package:flutter_appirc/app/ui/settings/local_preference/ui_settings_local_preferences_bloc.dart';
import 'package:flutter_appirc/app/ui/settings/local_preference/ui_settings_local_preferences_bloc_impl.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_bloc.dart';
import 'package:flutter_appirc/app/ui/settings/ui_settings_bloc_impl.dart';
import 'package:flutter_appirc/app/ui/theme/current/current_appirc_ui_theme_bloc.dart';
import 'package:flutter_appirc/app/ui/theme/current/current_appirc_ui_theme_bloc_impl.dart';
import 'package:flutter_appirc/app/ui/theme/dark/dark_appirc_ui_theme_model.dart';
import 'package:flutter_appirc/app/ui/theme/light/light_appirc_ui_theme_model.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:flutter_appirc/local_preferences/shared_preferences_local_preferences_service_impl.dart';
import 'package:flutter_appirc/provider/provider_context_bloc_impl.dart';
import 'package:flutter_appirc/pushes/push_service.dart';
import 'package:flutter_appirc/socketio/socket_io_service.dart';
import 'package:flutter_appirc/ui/theme/system/brightness/ui_theme_system_brightness_bloc.dart';
import 'package:flutter_appirc/ui/theme/system/brightness/ui_theme_system_brightness_bloc_impl.dart';
import 'package:logging/logging.dart';

var _logger = Logger("app_context_bloc_impl.dart");

class AppContextBloc extends ProviderContextBloc implements IAppContextBloc {
  @override
  Future internalAsyncInit() async {
    _logger.fine(() => "internalAsyncInit");

    var globalProviderService = this;

    var loggingService = LoggingService();
    await globalProviderService
        .asyncInitAndRegister<ILoggingService>(loggingService);
    addDisposable(disposable: loggingService);

    var socketIOService = SocketIOService();
    await globalProviderService
        .asyncInitAndRegister<SocketIOService>(socketIOService);
    addDisposable(disposable: socketIOService);

    var sharedPreferencesLocalPreferencesService =
        SharedPreferencesLocalPreferencesService();
    await globalProviderService.asyncInitAndRegister<ILocalPreferencesService>(
        sharedPreferencesLocalPreferencesService);
    addDisposable(disposable: sharedPreferencesLocalPreferencesService);

    var pushesService = PushesService();

    await pushesService.init();
    await pushesService.askPermissions();
    await pushesService.configure();
    addDisposable(disposable: pushesService);

    await globalProviderService
        .asyncInitAndRegister<PushesService>(pushesService);

    var chatDatabaseService = ChatDatabaseService();
    await globalProviderService
        .asyncInitAndRegister<ChatDatabaseService>(chatDatabaseService);
    addDisposable(disposable: chatDatabaseService);

    var currentInstanceLocalPreferenceBloc =
        CurrentAuthInstanceLocalPreferenceBloc(
            sharedPreferencesLocalPreferencesService);
    await globalProviderService
        .asyncInitAndRegister<ICurrentAuthInstanceLocalPreferenceBloc>(
            currentInstanceLocalPreferenceBloc);
    addDisposable(disposable: currentInstanceLocalPreferenceBloc);

    var currentInstanceBloc = CurrentAuthInstanceBloc(
        currentLocalPreferenceBloc: currentInstanceLocalPreferenceBloc);
    await globalProviderService
        .asyncInitAndRegister<ICurrentAuthInstanceBloc>(currentInstanceBloc);
    addDisposable(disposable: currentInstanceBloc);

    var uiSettingsLocalPreferencesBloc = UiSettingsLocalPreferencesBloc(
        sharedPreferencesLocalPreferencesService, "settings.ui");

    await globalProviderService.asyncInitAndRegister<
        IUiSettingsLocalPreferencesBloc>(uiSettingsLocalPreferencesBloc);
    addDisposable(disposable: uiSettingsLocalPreferencesBloc);

    var uiSettingsBloc = UiSettingsBloc(
      uiSettingsLocalPreferencesBloc: uiSettingsLocalPreferencesBloc,
    );

    await globalProviderService
        .asyncInitAndRegister<IUiSettingsBloc>(uiSettingsBloc);
    addDisposable(disposable: uiSettingsBloc);

    var uiThemeSystemBrightnessBloc = UiThemeSystemBrightnessBloc();

    await globalProviderService.asyncInitAndRegister<
        IUiThemeSystemBrightnessBloc>(uiThemeSystemBrightnessBloc);
    addDisposable(disposable: uiThemeSystemBrightnessBloc);

    var currentAppIrcUiThemeBloc = CurrentAppIrcUiThemeBloc(
      uiSettingsBloc: uiSettingsBloc,
      lightTheme: lightAppIrcUiTheme,
      darkTheme: darkAppIrcUiTheme,
      systemBrightnessHandlerBloc: uiThemeSystemBrightnessBloc,
      availableThemes: [
        lightAppIrcUiTheme,
        darkAppIrcUiTheme,
      ],
    );

    await globalProviderService.asyncInitAndRegister<ICurrentAppIrcUiThemeBloc>(
        currentAppIrcUiThemeBloc);

    addDisposable(disposable: currentAppIrcUiThemeBloc);

    var localizationSettingsLocalPreferencesBloc =
        LocalizationSettingsLocalPreferencesBloc(
            sharedPreferencesLocalPreferencesService, "settings.localization");

    await globalProviderService
        .asyncInitAndRegister<ILocalizationSettingsLocalPreferencesBloc>(
            localizationSettingsLocalPreferencesBloc);
    addDisposable(disposable: localizationSettingsLocalPreferencesBloc);

    var localizationSettingsBloc = LocalizationSettingsBloc(
      localizationSettingsLocalPreferencesBloc:
          localizationSettingsLocalPreferencesBloc,
    );

    await globalProviderService.asyncInitAndRegister<ILocalizationSettingsBloc>(
        localizationSettingsBloc);
    addDisposable(disposable: localizationSettingsBloc);
  }
}
