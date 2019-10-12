import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_connection_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_connection_preferences_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_alert_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "LoungePreferencesFormWidget", enabled: true);

class LoungePreferencesFormWidget extends StatefulWidget {
  final LoungePreferences startPreferences;
  final LoungePreferencesActionCallback callback;
  final String buttonText;

  LoungePreferencesFormWidget(this.startPreferences, this.callback,
      this.buttonText);

  @override
  State<StatefulWidget> createState() =>
      LoungePreferencesFormWidgetState(startPreferences, callback, buttonText);
}

class LoungePreferencesFormWidgetState
    extends State<LoungePreferencesFormWidget> {
  final LoungePreferences startValues;
  final LoungePreferencesActionCallback successCallback;
  final String buttonText;

  LoungePreferencesFormWidgetState(this.startValues, this.successCallback,
      this.buttonText);

  @override
  Widget build(BuildContext context) {
    LoungePreferencesFormBloc formBloc =
    Provider.of<LoungePreferencesFormBloc>(context);


    var connectionFormBloc = formBloc.connectionFormBloc;

    var authFormBloc = formBloc.authPreferencesFormBloc;
    var loungeAuthPreferencesFormWidget = LoungeAuthPreferencesFormWidget(
        authFormBloc.authPreferences);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                Provider(
                  providable: connectionFormBloc,
                  child: LoungeConnectionPreferencesFormWidget(
                      startValues.connectionPreferences),
                ),
                StreamBuilder<bool>(
                  stream: formBloc.isAuthFormEnabledStream,
                  initialData: formBloc.isAuthFormEnabled,
                  builder: (context, snapshot) {

                    var enabled = snapshot.data;
                    if(enabled) {


                      return Provider(
                        providable: authFormBloc,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: loungeAuthPreferencesFormWidget,
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }
                )
              ],
            ),
          ),
          StreamBuilder<bool>(
              stream: formBloc.dataValidStream,
              builder: (context, snapshot) {
                var pressed;
                var dataValid = snapshot.data != false;
                if (dataValid) {
                  pressed = () async {
                    try {
                      var currentLoungePreferences = formBloc.extractData();

                      ConnectResult connectResult =
                      await doAsyncOperationWithDialog(
                          context,
                              () async =>
                          await tryConnect(context, currentLoungePreferences));


                      if (connectResult.config != null) {
                        successCallback(context, currentLoungePreferences);
                      } else {

                        if(connectResult.isPrivateModeResponseReceived &&
                            !formBloc.isAuthFormEnabled) {
                          formBloc.isAuthFormEnabled = true;
                        } else {
                          PlatformAlertDialog dialog;
                          if (connectResult.isSocketConnected) {
                            if (connectResult.isFailAuthResponseReceived) {
                              dialog = buildLoungeAuthFailAlertDialog(context);
                            } else if (connectResult.isTimeout) {
                              dialog = buildLoungeTimeoutAlertDialog(context);
                            } else {
                              dialog = buildLoungeConnectionErrorAlertDialog(context, connectResult.error);
                            }
                          } else {
                            dialog = buildLoungeConnectionErrorAlertDialog(context, connectResult.error);
                          }

                          showPlatformDialog(
                              androidBarrierDismissible: true,
                              context: context,
                              builder: (_) => dialog);
                        }


                      }
                    } on InvalidConnectionResponseException catch (e) {
                      showPlatformDialog(
                          androidBarrierDismissible: true,
                          context: context,
                          builder: (_) =>
                              buildLoungeConnectionInvalidResponseDialog
                                (context, e));
                    }
                  };
                }

                return createSkinnedPlatformButton(
                  context,
                  child: Text(
                    buttonText,
                  ),
                  onPressed: pressed,
                );
              })
        ],
      ),
    );
  }

  Future<ConnectResult> tryConnect(BuildContext context,
      LoungePreferences preferences) async {
    var socketManagerProvider = Provider.of<SocketIOManagerProvider>(context);
    var lounge =
    LoungeBackendService(socketManagerProvider.manager, preferences);

    ConnectResult connectResult;

    var requestResult =
    await lounge.tryConnectWithDifferentPreferences(preferences);
    connectResult = requestResult.result;

    _logger.e(() => "tryConnect = $connectResult preferences = $preferences");

    return connectResult;
  }

  PlatformAlertDialog buildLoungeConnectionErrorAlertDialog(
      BuildContext context, dynamic error) {
    var appLocalizations = AppLocalizations.of(context);

    String title =
    appLocalizations.tr('lounge.preferences.connection.dialog.connection_error.title');

    String content;
    if (error != null) {
      content = appLocalizations.tr(
          'lounge.preferences.connection.dialog.connection_error'
              '.content_with_error',
          args: [error]);
    } else {
      content = appLocalizations
          .tr('lounge.preferences.connection.dialog.connection_error.content');
    }

    return PlatformAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[createOkPlatformDialogAction(context)]);
  }

  PlatformAlertDialog buildLoungeAuthFailAlertDialog(
      BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    String title =
    appLocalizations.tr('lounge.preferences.connection.dialog.auth_fail.title');

    String content = appLocalizations
        .tr('lounge.preferences.connection.dialog.auth_fail.content');


    return PlatformAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[createOkPlatformDialogAction(context)]);
  }
  PlatformAlertDialog buildLoungeTimeoutAlertDialog(
      BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    String title =
    appLocalizations.tr('lounge.preferences.connection.dialog.timeout.title');

    String content = appLocalizations
        .tr('lounge.preferences.connection.dialog.timeout.content');

    return PlatformAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[createOkPlatformDialogAction(context)]);
  }

  PlatformAlertDialog buildLoungeConnectionInvalidResponseDialog(
      BuildContext context, InvalidConnectionResponseException exception) {
    var appLocalizations = AppLocalizations.of(context);

    String title = appLocalizations
        .tr('lounge.preferences.connection.dialog.invalid_response_error.title');

    String content = appLocalizations
        .tr('lounge.preferences.connection.dialog.invalid_response_error.content');

    return PlatformAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[createOkPlatformDialogAction(context)]);
  }





}
