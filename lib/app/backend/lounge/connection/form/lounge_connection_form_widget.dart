import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_model.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/login/lounge_login_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/registration/lounge_registration_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_dialog_widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/host/lounge_host_preferences_form_widget.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/dialog/async/async_dialog_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/socketio/socket_io_service.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

MyLogger _logger =
    MyLogger(logTag: "lounge_connection_form_widget.dart", enabled: true);

typedef LoungePreferencesActionCallback = Function(
    BuildContext context, LoungePreferences preferences);

class LoungeConnectionFormWidget extends StatefulWidget {
  final LoungePreferences startPreferences;
  final LoungePreferencesActionCallback callback;

  LoungeConnectionFormWidget(this.startPreferences, this.callback) {
    _logger.d(() => "LoungeConnectionFormWidget constructor");
  }

  @override
  State<StatefulWidget> createState() =>
      LoungeConnectionFormWidgetState(startPreferences, callback);
}

class LoungeConnectionFormWidgetState
    extends State<LoungeConnectionFormWidget> {
  final LoungePreferences startPreferences;
  final LoungePreferencesActionCallback successCallback;

  LoungeConnectionFormWidgetState(this.startPreferences, this.successCallback);

  @override
  Widget build(BuildContext context) {
    _logger.d(() => "build");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildHostForm(context),
                _buildConnectButton(context),
                _buildAuthForm(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostForm(BuildContext context) {
    LoungeConnectionFormBloc formBloc = Provider.of(context);

    return LoungeHostPreferencesFormWidget(formBloc.hostFormBloc);
  }

  StreamBuilder<LoungeAuthState> _buildAuthForm(BuildContext context) {
    LoungeConnectionBloc connectionBloc = Provider.of(context);
    return StreamBuilder<LoungeAuthState>(
        stream: connectionBloc.stateStream,
        initialData: connectionBloc.state,
        builder: (context, snapshot) {
          var state = snapshot.data;

          if (state == null) {
            return SizedBox.shrink();
          }

          switch (state) {
            case LoungeAuthState.login:
              return _buildLoginForm(context);
              break;
            case LoungeAuthState.registration:
              return _buildRegistrationForm(context);
              break;
          }

          throw "Invalid state $state";
        });
  }

  StreamBuilder<bool> _buildConnectButton(BuildContext context) {
    LoungeConnectionFormBloc formBloc = Provider.of(context);

    LoungeConnectionBloc connectionBloc = Provider.of(context);

    return StreamBuilder<bool>(
      stream: connectionBloc.connectedStream,
      initialData: connectionBloc.connected,
      builder: (context, snapshot) {
        var connected = snapshot.data;

        if (connected) {
          return SizedBox.shrink();
        } else {
          return PlatformButton(
            onPressed: () async {
              var extractData = formBloc.extractData();
              AsyncDialogResult<RequestResult<LoungeHostInformation>>
                  asyncResult = await doAsyncOperationWithDialog(
                context: context,
                asyncCode: () {
                  return retrieveLoungeHostInformation(
                    SocketIOService.of(context, listen: false),
                    extractData.hostPreferences,
                  );
                },
                cancelable: true,
              );

              if (!asyncResult.canceled) {
                var requestResult = asyncResult.result;

                if (requestResult.isTimeout) {
                  await showLoungeTimeoutAlertDialog(context);
                } else {
                  if (requestResult.isResponseReceived) {
                    var hostInformation = requestResult.result;

                    if (hostInformation.connected &&
                        !hostInformation.authRequired) {
                      successCallback(context, extractData);
                    } else {
                      connectionBloc.onHostConnectionResult(
                          extractData.hostPreferences, hostInformation);

                      if (!hostInformation.connected) {
                        await showLoungeConnectionErrorAlertDialog(
                            context, requestResult.error);
                      }
                    }
                  } else {
                    await showLoungeConnectionErrorAlertDialog(
                        context, requestResult.error);
                  }
                }
              }
            },
            child: Text(
              S.of(context).lounge_preferences_host_action_connect,
            ),
          );
        }
      },
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    LoungeConnectionFormBloc formBloc = Provider.of(context);

    var loginFormBloc = formBloc.loginFormBloc;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: LoungeLoginFormWidget(loginFormBloc),
        ),
        _buildLoginButton(context),
        _buildSwitchToRegistrationButton(context),
      ],
    );
  }

  Widget _buildSwitchToRegistrationButton(BuildContext context) {
    LoungeConnectionBloc connectionBloc = Provider.of(context);
    return StreamBuilder<bool>(
      stream: connectionBloc.isRegistrationSupportedStream,
      initialData: connectionBloc.isRegistrationSupported,
      builder: (context, snapshot) {
        var registrationSupported = snapshot.data;
        return registrationSupported
            ? PlatformButton(
                onPressed: () {
                  connectionBloc.switchToRegistration();
                },
                child: Text(
                  S.of(context).lounge_preferences_action_switch_to_sign_up,
                ),
              )
            : SizedBox.shrink();
      },
    );
  }

  StreamBuilder<bool> _buildLoginButton(BuildContext context) {
    LoungeConnectionFormBloc formBloc = Provider.of(context);
    var loginFormBloc = formBloc.loginFormBloc;
    return StreamBuilder<bool>(
      initialData: loginFormBloc.isDataValid,
      stream: loginFormBloc.dataValidStream,
      builder: (context, snapshot) {
        var dataValid = snapshot.data;

        return PlatformButton(
          onPressed: dataValid
              ? () async {
                  var connectionFormBloc =
                      Provider.of<LoungeConnectionFormBloc>(context);
                  var extractData = connectionFormBloc.extractData();
                  var asyncResult = await doAsyncOperationWithDialog(
                    context: context,
                    asyncCode: () async {
                      return await tryLoginToLounge(
                        Provider.of<SocketIOService>(context),
                        extractData,
                      );
                    },
                    cancelable: true,
                  );

                  if (!asyncResult.canceled) {
                    var requestResult = asyncResult.result;

                    if (requestResult.isTimeout) {
                      await showLoungeTimeoutAlertDialog(context);
                    } else {
                      if (requestResult.isResponseReceived) {
                        ChatLoginResult loginResult = requestResult.result;

                        if (loginResult.success) {
                          successCallback(context, extractData);
                        } else {
                          await showLoungeLoginFailAlertDialog(context);
                        }
                      } else {
                        await showLoungeConnectionErrorAlertDialog(
                          context,
                          requestResult.error,
                        );
                      }
                    }
                  }
                }
              : null,
          child: Text(
            S.of(context).lounge_preferences_login_action_login,
          ),
        );
      },
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    LoungeConnectionFormBloc formBloc = Provider.of(context);
    var registrationFormBloc = formBloc.registrationFormBloc;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: LoungeRegistrationFormWidget(registrationFormBloc),
        ),
        _buildRegisterButton(context),
        _buildSwitchToRegisterButton(context),
      ],
    );
  }

  StreamBuilder<bool> _buildRegisterButton(BuildContext context) {
    LoungeConnectionFormBloc formBloc = Provider.of(context);
    var registrationFormBloc = formBloc.registrationFormBloc;
    return StreamBuilder<bool>(
      initialData: registrationFormBloc.isDataValid,
      stream: registrationFormBloc.dataValidStream,
      builder: (context, snapshot) {
        var dataValid = snapshot.data;

        return PlatformButton(
          onPressed: dataValid
              ? () async {
                  var connectionFormBloc =
                      Provider.of<LoungeConnectionFormBloc>(context);
                  var extractData = connectionFormBloc.extractData();
                  var asyncResult = await doAsyncOperationWithDialog(
                    context: context,
                    asyncCode: () async {
                      return await registerOnLounge(
                        Provider.of<SocketIOService>(context),
                        extractData,
                      );
                    },
                    cancelable: true,
                  );

                  if (!asyncResult.canceled) {
                    var requestResult = asyncResult.result;

                    if (requestResult.isTimeout) {
                      await showLoungeTimeoutAlertDialog(context);
                    } else {
                      if (requestResult.isResponseReceived) {
                        ChatRegistrationResult registrationResult =
                            requestResult.result;

                        if (registrationResult.success) {
                          successCallback(context, extractData);
                        } else {
                          switch (registrationResult.errorType) {
                            case RegistrationErrorType.alreadyExist:
                              await showLoungeRegistrationAlreadyExistAlertDialog(
                                  context);
                              break;
                            case RegistrationErrorType.invalid:
                              await showLoungeRegistrationInvalidAlertDialog(
                                  context);
                              break;
                            case RegistrationErrorType.unknown:
                              await showLoungeRegistrationUnknownAlertDialog(
                                  context);
                              break;
                          }
                        }
                      } else {
                        await showLoungeConnectionErrorAlertDialog(
                          context,
                          requestResult.error,
                        );
                      }
                    }
                  }
                }
              : null,
          child: Text(
            S.of(context).lounge_preferences_registration_action_register,
          ),
        );
      },
    );
  }

  Widget _buildSwitchToRegisterButton(BuildContext context) {
    LoungeConnectionBloc connectionBloc = Provider.of(context);
    return PlatformButton(
      onPressed: () {
        connectionBloc.switchToLogin();
      },
      child: Text(
        S.of(context).lounge_preferences_action_switch_to_sign_in,
      ),
    );
  }
}
