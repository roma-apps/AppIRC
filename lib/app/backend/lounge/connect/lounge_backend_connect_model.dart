import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/socket_io/socket_io_model.dart';

enum LoungeBackendConnectState {
  connected,
  connecting,
  disconnected,
}

extension LoungeSimpleSocketIoConnectionStateExtension
    on SimpleSocketIoConnectionState {
  LoungeBackendConnectState toLoungeBackendConnectState() {
    switch (this) {
      case SimpleSocketIoConnectionState.initialized:
        return LoungeBackendConnectState.disconnected;
        break;
      case SimpleSocketIoConnectionState.connected:
        return LoungeBackendConnectState.connected;
        break;
      case SimpleSocketIoConnectionState.connecting:
        return LoungeBackendConnectState.connecting;
        break;
      case SimpleSocketIoConnectionState.disconnected:
        return LoungeBackendConnectState.disconnected;
        break;
    }

    throw "Invalid $this";
  }
}

class LoungeConnectDetailsPrivatePart extends LoungeComplexResponse {
  final SignUpAvailableLoungeResponseBody signUpAvailableResponseBody;
  final AuthStartLoungeResponseBody authStartLoungeResponseBody;

  @override
  List<dynamic> get optionalFields => [signUpAvailableResponseBody];

  @override
  List<dynamic> get requiredFields => [authStartLoungeResponseBody];

  LoungeConnectDetailsPrivatePart({
    @required this.signUpAvailableResponseBody,
    @required this.authStartLoungeResponseBody,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectDetailsPrivatePart &&
          runtimeType == other.runtimeType &&
          signUpAvailableResponseBody == other.signUpAvailableResponseBody &&
          authStartLoungeResponseBody == other.authStartLoungeResponseBody;

  @override
  int get hashCode =>
      signUpAvailableResponseBody.hashCode ^
      authStartLoungeResponseBody.hashCode;

  @override
  String toString() {
    return 'LoungeConnectDetailsPrivatePart{'
        'signUpAvailableResponseBody: $signUpAvailableResponseBody, '
        'authStartLoungeResponseBody: $authStartLoungeResponseBody'
        '}';
  }
}

class LoungeConnectDetailsPublicPart extends LoungeComplexResponse {
  final AuthSuccessComplexLoungeResponse authSuccessComplexLoungeResponse;

  @override
  List<dynamic> get optionalFields => [
        ...authSuccessComplexLoungeResponse.optionalFields,
      ];

  @override
  List<dynamic> get requiredFields => [
        ...authSuccessComplexLoungeResponse.requiredFields,
      ];

  LoungeConnectDetailsPublicPart({
    @required this.authSuccessComplexLoungeResponse,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectDetailsPublicPart &&
          runtimeType == other.runtimeType &&
          authSuccessComplexLoungeResponse ==
              other.authSuccessComplexLoungeResponse;

  @override
  int get hashCode => authSuccessComplexLoungeResponse.hashCode;

  @override
  String toString() {
    return 'LoungeConnectDetailsPublicPart{'
        'authSuccessComplexLoungeResponse: $authSuccessComplexLoungeResponse'
        '}';
  }
}

class LoungeConnectAndAuthDetails {
  final LoungeConnectDetails connectDetails;
  final AuthPerformComplexLoungeResponse authPerformComplexLoungeResponse;

  const LoungeConnectAndAuthDetails({
    @required this.connectDetails,
    @required this.authPerformComplexLoungeResponse,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectAndAuthDetails &&
          runtimeType == other.runtimeType &&
          connectDetails == other.connectDetails &&
          authPerformComplexLoungeResponse ==
              other.authPerformComplexLoungeResponse;

  @override
  int get hashCode =>
      connectDetails.hashCode ^ authPerformComplexLoungeResponse.hashCode;

  @override
  String toString() {
    return 'LoungeConnectAndAuthDetails{'
        'connectDetails: $connectDetails, '
        'authPerformComplexLoungeResponse: $authPerformComplexLoungeResponse'
        '}';
  }
}

class LoungeConnectDetails {
  final bool isSocketError;
  final bool isSocketTimeout;
  final bool isLoungeNotSentRequiredDataAndTimeoutReached;

  LoungeBackendMode get backendMode {
    if (publicPart != null) {
      return LoungeBackendMode.public;
    }

    if (privatePart != null) {
      return LoungeBackendMode.private;
    }

    return null;
  }

  final LoungeConnectDetailsPublicPart publicPart;
  final LoungeConnectDetailsPrivatePart privatePart;

  LoungeConnectDetails._private({
    @required this.isSocketError,
    @required this.isSocketTimeout,
    @required this.publicPart,
    @required this.privatePart,
    @required this.isLoungeNotSentRequiredDataAndTimeoutReached,
  });

  LoungeConnectDetails.socketTimeout()
      : this._private(
          isSocketTimeout: true,
          isSocketError: false,
          publicPart: null,
          privatePart: null,
          isLoungeNotSentRequiredDataAndTimeoutReached: false,
        );

  LoungeConnectDetails.loungeNotSentRequiredDataAndTimeoutReached()
      : this._private(
          isSocketTimeout: false,
          isSocketError: false,
          publicPart: null,
          privatePart: null,
          isLoungeNotSentRequiredDataAndTimeoutReached: true,
        );

  LoungeConnectDetails.socketError()
      : this._private(
          isSocketTimeout: false,
          isSocketError: true,
          publicPart: null,
          privatePart: null,
          isLoungeNotSentRequiredDataAndTimeoutReached: false,
        );

  LoungeConnectDetails.public({
    @required LoungeConnectDetailsPublicPart publicPart,
  }) : this._private(
          isSocketTimeout: false,
          isSocketError: false,
          publicPart: publicPart,
          privatePart: null,
          isLoungeNotSentRequiredDataAndTimeoutReached: false,
        );

  LoungeConnectDetails.private({
    @required LoungeConnectDetailsPrivatePart privatePart,
  }) : this._private(
          isSocketTimeout: false,
          isSocketError: false,
          publicPart: null,
          privatePart: privatePart,
          isLoungeNotSentRequiredDataAndTimeoutReached: false,
        );

  bool get connected => backendMode != null;

  bool get isPrivateMode => backendMode == LoungeBackendMode.private;
  bool get isPublicMode => backendMode == LoungeBackendMode.public;

  bool get isSuccess {
    if(backendMode == null) {
      return false;
    }

    if(isPublicMode) {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectDetails &&
          runtimeType == other.runtimeType &&
          isSocketError == other.isSocketError &&
          isSocketTimeout == other.isSocketTimeout &&
          publicPart == other.publicPart &&
          privatePart == other.privatePart;

  @override
  int get hashCode =>
      isSocketError.hashCode ^
      isSocketTimeout.hashCode ^
      publicPart.hashCode ^
      privatePart.hashCode;

  @override
  String toString() => 'LoungeConnectDetails{'
      'isSocketError: $isSocketError, '
      'isSocketTimeout: $isSocketTimeout, '
      'backendMode: $backendMode, '
      'publicPart: $publicPart, '
      'privatePart: $privatePart'
      '}';
}

enum LoungeBackendAuthState {
  notLogged,
  loginFailed,
  waitForAuth,
  logged,
}

class AuthPerformComplexLoungeResponse extends LoungeComplexResponse {
  final AuthSuccessComplexLoungeResponse authSuccessComplexLoungeResponse;
  final bool authFailedReceived;
  final bool loungeNotSentRequiredDataAndTimeoutReached;

  bool get isSuccess => authSuccessComplexLoungeResponse != null;

  bool get isFail =>
      authFailedReceived == true ||
      loungeNotSentRequiredDataAndTimeoutReached == true;

  @override
  List<dynamic> get optionalFields => [];

  @override
  List<dynamic> get requiredFields => throw "Unsupported";

  @override
  bool get isRequiredFieldsExist =>
      authSuccessComplexLoungeResponse?.isRequiredFieldsExist == true ||
      authFailedReceived == true;

  AuthPerformComplexLoungeResponse._private({
    @required this.authSuccessComplexLoungeResponse,
    @required this.authFailedReceived,
    @required this.loungeNotSentRequiredDataAndTimeoutReached,
  });

  AuthPerformComplexLoungeResponse.response({
    @required AuthSuccessComplexLoungeResponse authSuccessComplexLoungeResponse,
    @required bool authFailedReceived,
  }) : this._private(
          authSuccessComplexLoungeResponse: authSuccessComplexLoungeResponse,
          authFailedReceived: authFailedReceived,
          loungeNotSentRequiredDataAndTimeoutReached: false,
        );

  AuthPerformComplexLoungeResponse.loungeNotSentRequiredDataAndTimeoutReached()
      : this._private(
          authSuccessComplexLoungeResponse: null,
          authFailedReceived: null,
          loungeNotSentRequiredDataAndTimeoutReached: true,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthPerformComplexLoungeResponse &&
          runtimeType == other.runtimeType &&
          authSuccessComplexLoungeResponse ==
              other.authSuccessComplexLoungeResponse &&
          authFailedReceived == other.authFailedReceived;

  @override
  int get hashCode =>
      authSuccessComplexLoungeResponse.hashCode ^ authFailedReceived.hashCode;

  @override
  String toString() {
    return 'AuthPerformComplexLoungeResponse{'
        'authSuccessComplexLoungeResponse: $authSuccessComplexLoungeResponse, '
        'authFailedReceived: $authFailedReceived'
        '}';
  }
}

class AuthSuccessComplexLoungeResponse extends LoungeComplexResponse {
  final ConfigurationLoungeResponseBody configurationLoungeResponseBody;
  final InitLoungeResponseBody initLoungeResponseBody;
  final CommandsLoungeResponseBody commandsLoungeResponseBody;
  final PushIsSubscribedLoungeResponseBody pushIsSubscribedLoungeResponseBody;

  @override
  List<dynamic> get optionalFields => [
        commandsLoungeResponseBody,
        pushIsSubscribedLoungeResponseBody,
      ];

  @override
  List<dynamic> get requiredFields => [
        configurationLoungeResponseBody,
        initLoungeResponseBody,
      ];

  AuthSuccessComplexLoungeResponse({
    @required this.configurationLoungeResponseBody,
    @required this.initLoungeResponseBody,
    @required this.commandsLoungeResponseBody,
    @required this.pushIsSubscribedLoungeResponseBody,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSuccessComplexLoungeResponse &&
          runtimeType == other.runtimeType &&
          configurationLoungeResponseBody ==
              other.configurationLoungeResponseBody &&
          initLoungeResponseBody == other.initLoungeResponseBody &&
          commandsLoungeResponseBody == other.commandsLoungeResponseBody &&
          pushIsSubscribedLoungeResponseBody ==
              other.pushIsSubscribedLoungeResponseBody;

  @override
  int get hashCode =>
      configurationLoungeResponseBody.hashCode ^
      initLoungeResponseBody.hashCode ^
      commandsLoungeResponseBody.hashCode ^
      pushIsSubscribedLoungeResponseBody.hashCode;

  @override
  String toString() {
    return 'AuthSuccessComplexLoungeResponse{'
        'configurationLoungeResponseBody: $configurationLoungeResponseBody, '
        'initLoungeResponseBody: $initLoungeResponseBody, '
        'commandsLoungeResponseBody: $commandsLoungeResponseBody, '
        'pushIsSubscribedLoungeResponseBody: $pushIsSubscribedLoungeResponseBody'
        '}';
  }
}
