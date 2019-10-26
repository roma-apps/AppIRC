import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/connection/lounge_connection_preferences_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/form/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/async/async_dialog_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';

typedef LoungePreferencesActionCallback =
Function(BuildContext context, LoungePreferences preferences);

var _logger = MyLogger(
    logTag: "lounge_preferences_form_widget.dart", enabled: true);



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
  final LoungePreferences startPreferences;
  final LoungePreferencesActionCallback successCallback;
  final String buttonText;

  LoungePreferencesFormWidgetState(this.startPreferences, this.successCallback,
      this.buttonText);

  @override
  Widget build(BuildContext context) {
    LoungePreferencesFormBloc formBloc = Provider.of<LoungePreferencesFormBloc>(
        context);

    var loungeAuthPreferencesFormWidget = LoungeAuthPreferencesFormWidget(
        startPreferences.authPreferences);

    return Padding(padding: const EdgeInsets.all(8.0),
      child: Column(children: <Widget>[
        Expanded(child: ListView(children: <Widget>[
          Provider(providable: formBloc.connectionFormBloc,
            child: LoungeConnectionPreferencesFormWidget(
                startPreferences.connectionPreferences),),
          StreamBuilder<bool>(stream: formBloc.isAuthFormEnabledStream,
              initialData: formBloc.isAuthFormEnabled,
              builder: (context, snapshot) {
                var enabled = snapshot.data;
                if (enabled) {
                  return Provider(providable: formBloc.authPreferencesFormBloc,
                    child: Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0,
                        0), child: loungeAuthPreferencesFormWidget,),);
                } else {
                  return SizedBox.shrink();
                }
              }),
        ],),),
        StreamBuilder<bool>(
            stream: formBloc.dataValidStream, builder: (context, snapshot) {
          var pressed;
          var dataValid = snapshot.data != false;
          if (dataValid) {
            pressed = () async {
              try {
                var currentLoungePreferences = formBloc.extractData();

                AsyncDialogResult<ConnectResult> dialogResult;

                dialogResult = await doAsyncOperationWithDialog(context,
                    asyncCode: () async => await tryConnect(
                        context, currentLoungePreferences),
                    cancellationValue: null,
                    isDismissible: true);

                if (dialogResult.isNotCanceled) {
                  ConnectResult connectResult = dialogResult.result;

                  if (connectResult.config != null) {
                    successCallback(context, currentLoungePreferences);
                  } else {
                    if (connectResult.isPrivateModeResponseReceived &&
                        !formBloc.isAuthFormEnabled) {
                      formBloc.isAuthFormEnabled = true;
                    } else {
                      if (connectResult.isSocketConnected) {
                        if (connectResult.isFailAuthResponseReceived) {
                          showLoungeAuthFailAlertDialog(context);
                        } else if (connectResult.isTimeout) {
                          showLoungeTimeoutAlertDialog(context);
                        } else {
                          showLoungeConnectionErrorAlertDialog(
                              context, connectResult.error);
                        }
                      } else {
                        showLoungeConnectionErrorAlertDialog(
                            context, connectResult.error);
                      }
                    }
                  }
                }
              } on InvalidConnectionResponseException catch (e) {
                showLoungeConnectionInvalidResponseDialog(context, e);
              }
            };
          }

          return createSkinnedPlatformButton(
            context, child: Text(buttonText,), onPressed: pressed,);
        })
      ],),);
  }

  Future<ConnectResult> tryConnect(BuildContext context,
      LoungePreferences preferences) async {
    var socketManagerProvider = Provider.of<SocketIOManagerProvider>(context);
    var lounge = LoungeBackendService(
        socketManagerProvider.manager, preferences);

    ConnectResult connectResult;

    var requestResult = await lounge.tryConnectWithDifferentPreferences(
        preferences);
    connectResult = requestResult.result;

    _logger.e(() => "tryConnect = $connectResult preferences = $preferences");

    return connectResult;
  }

  Future showLoungeConnectionErrorAlertDialog(BuildContext context,
      dynamic error) async {
    var appLocalizations = AppLocalizations.of(context);

    String title = appLocalizations.tr(
        'lounge.preferences.connection.dialog.connection_error.title');

    String content;
    if (error != null) {
      content = appLocalizations.tr(
          'lounge.preferences.connection.dialog.connection_error'
              '.content.with_exception', args: [error]);
    } else {
      content = appLocalizations.tr(
          'lounge.preferences.connection.dialog.connection_error.content'
              '.no_exception');
    }

    return showPlatformAlertDialog(
        context: context, title: Text(title), content: Text(content));
  }

  Future showLoungeAuthFailAlertDialog(BuildContext context) async {
    var appLocalizations = AppLocalizations.of(context);

    String title = appLocalizations.tr(
        'lounge.preferences.connection.dialog.auth_fail.title');

    String content = appLocalizations.tr(
        'lounge.preferences.connection.dialog.auth_fail.content');

    return showPlatformAlertDialog(
        context: context, title: Text(title), content: Text(content));
  }

  Future showLoungeTimeoutAlertDialog(BuildContext context) async {
    var appLocalizations = AppLocalizations.of(context);

    String title = appLocalizations.tr(
        'lounge.preferences.connection.dialog.timeout.title');

    String content = appLocalizations.tr(
        'lounge.preferences.connection.dialog.timeout.content');

    return showPlatformAlertDialog(
        context: context, title: Text(title), content: Text(content));
  }

  Future showLoungeConnectionInvalidResponseDialog(BuildContext context,
      InvalidConnectionResponseException exception) async {
    var appLocalizations = AppLocalizations.of(context);

    String title = appLocalizations.tr(
        'lounge.preferences.connection.dialog.invalid_response_error.title');

    String content = appLocalizations.tr(
        'lounge.preferences.connection.dialog.invalid_response_error.content');

    return showPlatformAlertDialog(
        context: context, title: Text(title), content: Text(content));
  }
}
