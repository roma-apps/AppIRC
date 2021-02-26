import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/api/lounge_backend_socket_io_api_wrapper_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_model.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/login/lounge_login_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/login/lounge_login_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_model.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/registration/lounge_registration_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/registration/lounge_registration_form_widget.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_dialog_widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/host/lounge_host_preferences_form_widget.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/dialog/async/async_dialog_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/socket_io/instance/socket_io_instance_bloc.dart';
import 'package:flutter_appirc/socket_io/socket_io_service.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("lounge_connection_form_widget.dart");

typedef LoungePreferencesActionCallback = Function(
    BuildContext context, LoungePreferences preferences);

class LoungeConnectionFormWidget extends StatelessWidget {
  final LoungePreferences startPreferences;
  final LoungePreferencesActionCallback successCallback;

  LoungeConnectionFormWidget({
    @required this.startPreferences,
    @required this.successCallback,
  });

  @override
  Widget build(BuildContext context) {
    _logger.fine(() => "build");

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
      },
    );
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
              var loungePreferences = formBloc.extractData();
              AsyncDialogResult<LoungeConnectDetails> asyncResult =
                  await doAsyncOperationWithDialog(
                context: context,
                asyncCode: () async {
                  SocketIOInstanceBloc socketIOInstanceBloc;
                  LoungeBackendConnectBloc loungeBackendConnectBloc;

                  LoungeConnectDetails result;

                  try {
                    socketIOInstanceBloc = SocketIOInstanceBloc(
                      socketIoService: SocketIOService.of(
                        context,
                        listen: false,
                      ),
                      uri: loungePreferences.hostPreferences.host,
                    );

                    await socketIOInstanceBloc.performAsyncInit();

                    loungeBackendConnectBloc = LoungeBackendConnectBloc(
                      loungeAuthPreferences: loungePreferences.authPreferences,
                      loungeBackendSocketIoApiWrapperBloc:
                          LoungeBackendSocketIoApiWrapperBloc(
                        socketIOInstanceBloc: socketIOInstanceBloc,
                      ),
                    );

                    result = await loungeBackendConnectBloc
                        .connectAndWaitForResult();
                  } finally {
                    await socketIOInstanceBloc?.dispose();
                    await loungeBackendConnectBloc?.dispose();
                  }
                  return result;
                },
                cancelable: true,
              );

              if (!asyncResult.canceled) {
                var requestResult = asyncResult.result;

                if (requestResult.isSocketTimeout) {
                  await showLoungeTimeoutAlertDialog(context);
                } else {
                  if (!requestResult
                      .isLoungeNotSentRequiredDataAndTimeoutReached) {
                    var hostInformation = requestResult;

                    if (hostInformation.connected &&
                        !hostInformation.isPrivateMode) {
                      successCallback(context, loungePreferences);
                    } else {
                      connectionBloc.onHostConnectionResult(
                        loungePreferences.hostPreferences,
                        hostInformation,
                      );

                      if (!hostInformation.connected) {
                        await showLoungeConnectionErrorAlertDialog(
                          context,
                          null,
                        );
                      }
                    }
                  } else {
                    await showLoungeConnectionErrorAlertDialog(context, null);
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: ProxyProvider<LoungeConnectionFormBloc,
              LoungeAuthPreferencesFormBloc>(
            update: (context, value, _) => value.loginFormBloc,
            child: ProxyProvider<LoungeConnectionFormBloc, LoungeLoginFormBloc>(
              update: (context, value, _) => value.loginFormBloc,
              child: LoungeLoginFormWidget(),
            ),
          ),
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
                      Provider.of<LoungeConnectionFormBloc>(
                    context,
                    listen: false,
                  );
                  var loungePreferences = connectionFormBloc.extractData();
                  var asyncResult = await doAsyncOperationWithDialog<LoungeConnectAndAuthDetails>(
                    context: context,
                    asyncCode: () async {
                      var socketIOService = Provider.of<SocketIOService>(
                        context,
                        listen: false,
                      );

                      SocketIOInstanceBloc socketIOInstanceBloc;
                      LoungeBackendConnectBloc loungeBackendConnectBloc;

                      LoungeConnectAndAuthDetails loungeConnectAndAuthDetails;
                      try {
                        socketIOInstanceBloc = SocketIOInstanceBloc(
                          uri: loungePreferences.hostPreferences.host,
                          socketIoService: socketIOService,
                        );

                        await socketIOInstanceBloc.performAsyncInit();

                        var loungeBackendSocketIoApiWrapperBloc =
                            LoungeBackendSocketIoApiWrapperBloc(
                                socketIOInstanceBloc: socketIOInstanceBloc);

                        loungeBackendConnectBloc = LoungeBackendConnectBloc(
                          loungeBackendSocketIoApiWrapperBloc:
                              loungeBackendSocketIoApiWrapperBloc,
                          loungeAuthPreferences:
                              loungePreferences.authPreferences,
                        );

                        loungeConnectAndAuthDetails = await loungeBackendConnectBloc
                            .connectAndLoginAndWaitForResult();
                      } finally {
                        await socketIOInstanceBloc?.dispose();
                        await loungeBackendConnectBloc?.dispose();
                      }

                      return loungeConnectAndAuthDetails;
                    },
                    cancelable: true,
                  );

                  if (!asyncResult.canceled) {
                    var requestResult = asyncResult.result;

                    if (requestResult.connectDetails.isSocketTimeout) {
                      await showLoungeTimeoutAlertDialog(context);
                    } else {
                      if (requestResult.authPerformComplexLoungeResponse != null) {
                        var success =requestResult.authPerformComplexLoungeResponse.isSuccess;

                        if (success) {
                          successCallback(
                            context,
                            loungePreferences,
                          );
                        } else {
                          await showLoungeLoginFailAlertDialog(context);
                        }
                      } else {
                        await showLoungeConnectionErrorAlertDialog(
                          context,
                          null
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: ProxyProvider<LoungeConnectionFormBloc,
              LoungeRegistrationFormBloc>(
            update: (context, value, _) => value.registrationFormBloc,
            child: LoungeRegistrationFormWidget(),
          ),
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
                  var loungePreferences = connectionFormBloc.extractData();
                  var asyncResult = await doAsyncOperationWithDialog<
                      SignedUpLoungeResponseBody>(
                    context: context,
                    asyncCode: () async {
                      var socketIOService =
                          Provider.of<SocketIOService>(context);

                      SocketIOInstanceBloc socketIOInstanceBloc;

                      SignedUpLoungeResponseBody signedUpLoungeResponseBody;
                      try {
                        socketIOInstanceBloc = SocketIOInstanceBloc(
                          uri: loungePreferences.hostPreferences.host,
                          socketIoService: socketIOService,
                        );

                        await socketIOInstanceBloc.performAsyncInit();

                        var loungeBackendSocketIoApiWrapperBloc =
                            LoungeBackendSocketIoApiWrapperBloc(
                                socketIOInstanceBloc: socketIOInstanceBloc);

                        signedUpLoungeResponseBody =
                            await loungeBackendSocketIoApiWrapperBloc
                                .sendSignUpAndWaitForResult(
                          user: loungePreferences.authPreferences.username,
                          password: loungePreferences.authPreferences.password,
                        );
                      } finally {
                        await socketIOInstanceBloc?.dispose();
                      }

                      return signedUpLoungeResponseBody;
                    },
                    cancelable: true,
                  );

                  if (!asyncResult.canceled) {
                    var requestResult = asyncResult.result;

                    var registrationResult =
                        toChatRegistrationResult(requestResult);

                    if (registrationResult.success) {
                      successCallback(context, loungePreferences);
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
