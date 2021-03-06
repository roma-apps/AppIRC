import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/socket_io/socket_io_model.dart';
import 'package:logging/logging.dart';

final _logger = Logger("lounge_backend_connect_model.dart");

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

  final Auth4xStartLoungeResponseBody auth4xStartLoungeResponseBody;
  final Auth3xLoungeResponseBody auth3xLoungeResponseBody;

  LoungeVersion get loungeVersion {
    var isLounge3x = auth3xLoungeResponseBody != null;
    var isLounge4x = auth4xStartLoungeResponseBody != null;
    assert(!(isLounge3x && isLounge4x));
    if (!isLounge3x && !isLounge4x) {
      return null;
    } else if (isLounge4x) {
      return LoungeVersion.version4_x;
    } else {
      return LoungeVersion.version3_x;
    }
  }

  @override
  List<dynamic> get optionalFields => [
        signUpAvailableResponseBody,
      ];

  @override
  List<dynamic> get requiredFields =>
      throw UnsupportedError("Only isRequiredFieldsExist is available");

  @override
  bool get isRequiredFieldsExist =>
      auth4xStartLoungeResponseBody != null || auth3xLoungeResponseBody != null;

  LoungeConnectDetailsPrivatePart({
    @required this.signUpAvailableResponseBody,
    @required this.auth4xStartLoungeResponseBody,
    @required this.auth3xLoungeResponseBody,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectDetailsPrivatePart &&
          runtimeType == other.runtimeType &&
          signUpAvailableResponseBody == other.signUpAvailableResponseBody &&
          auth3xLoungeResponseBody == other.auth3xLoungeResponseBody &&
          auth4xStartLoungeResponseBody == other.auth4xStartLoungeResponseBody;

  @override
  int get hashCode =>
      auth3xLoungeResponseBody.hashCode ^
      signUpAvailableResponseBody.hashCode ^
      auth4xStartLoungeResponseBody.hashCode;

  @override
  String toString() {
    return 'LoungeConnectDetailsPrivatePart{'
        'authLoungeResponseBody: $auth3xLoungeResponseBody, '
        'signUpAvailableResponseBody: $signUpAvailableResponseBody, '
        'authStartLoungeResponseBody: $auth4xStartLoungeResponseBody'
        '}';
  }
}

class LoungeConnectDetailsPublicPart extends LoungeComplexResponse {
  final Auth4xSuccessComplexLoungeResponse auth4xSuccessComplexLoungeResponse;
  final Authorized3xComplexLoungeResponse authorized3xComplexLoungeResponse;

  LoungeVersion get loungeVersion {
    var isLounge3x =
        authorized3xComplexLoungeResponse?.isRequiredFieldsExist == true;
    var isLounge4x =
        auth4xSuccessComplexLoungeResponse?.isRequiredFieldsExist == true;
    assert(!(isLounge3x && isLounge4x));
    if (!isLounge3x && !isLounge4x) {
      return null;
    } else if (isLounge4x) {
      return LoungeVersion.version4_x;
    } else {
      return LoungeVersion.version3_x;
    }
  }

  @override
  List<dynamic> get optionalFields =>
      throw UnsupportedError("Only isOptionalFieldsExist is available");

  @override
  List<dynamic> get requiredFields =>
      throw UnsupportedError("Only isRequiredFieldsExist is available");

  @override
  bool get isOptionalFieldsExist =>
      auth4xSuccessComplexLoungeResponse?.isOptionalFieldsExist == true ||
      authorized3xComplexLoungeResponse?.isOptionalFieldsExist == true;

  @override
  bool get isRequiredFieldsExist =>
      auth4xSuccessComplexLoungeResponse?.isRequiredFieldsExist == true ||
      authorized3xComplexLoungeResponse?.isRequiredFieldsExist == true;

  LoungeConnectDetailsPublicPart({
    @required this.auth4xSuccessComplexLoungeResponse,
    @required this.authorized3xComplexLoungeResponse,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectDetailsPublicPart &&
          runtimeType == other.runtimeType &&
          auth4xSuccessComplexLoungeResponse ==
              other.auth4xSuccessComplexLoungeResponse &&
          authorized3xComplexLoungeResponse ==
              other.authorized3xComplexLoungeResponse;

  @override
  int get hashCode =>
      auth4xSuccessComplexLoungeResponse.hashCode ^
      authorized3xComplexLoungeResponse.hashCode;

  @override
  String toString() {
    return 'LoungeConnectDetailsPublicPart{'
        'authSuccessComplexLoungeResponse: $auth4xSuccessComplexLoungeResponse, '
        'authorizedComplexLoungeResponse: $authorized3xComplexLoungeResponse'
        '}';
  }
}

class LoungeConnectAndAuthDetails {
  final LoungeConnectDetails connectDetails;
  final Auth4xPerformComplexLoungeResponse auth4xPerformComplexLoungeResponse;
  final Auth3xComplexLoungeResponse auth3xComplexLoungeResponse;

  bool get isAuthUsed =>
      auth4xPerformComplexLoungeResponse != null ||
      auth3xComplexLoungeResponse != null;

  bool get success =>
      connectDetails.publicPart != null ||
      auth4xPerformComplexLoungeResponse?.isSuccess == true ||
      auth3xComplexLoungeResponse?.isSuccess == true;

  const LoungeConnectAndAuthDetails.private({
    @required this.connectDetails,
    @required this.auth4xPerformComplexLoungeResponse,
    @required this.auth3xComplexLoungeResponse,
  });

  const LoungeConnectAndAuthDetails.version3x({
    @required LoungeConnectDetails connectDetails,
    @required Auth3xComplexLoungeResponse auth3xComplexLoungeResponse,
  }) : this.private(
          connectDetails: connectDetails,
          auth3xComplexLoungeResponse: auth3xComplexLoungeResponse,
          auth4xPerformComplexLoungeResponse: null,
        );

  const LoungeConnectAndAuthDetails.version4x({
    @required LoungeConnectDetails connectDetails,
    @required
        Auth4xPerformComplexLoungeResponse auth4xPerformComplexLoungeResponse,
  }) : this.private(
          connectDetails: connectDetails,
          auth3xComplexLoungeResponse: null,
          auth4xPerformComplexLoungeResponse:
              auth4xPerformComplexLoungeResponse,
        );

  bool get isResponseExist =>
      auth4xPerformComplexLoungeResponse != null ||
      auth3xComplexLoungeResponse != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeConnectAndAuthDetails &&
          runtimeType == other.runtimeType &&
          connectDetails == other.connectDetails &&
          auth4xPerformComplexLoungeResponse ==
              other.auth4xPerformComplexLoungeResponse &&
          auth3xComplexLoungeResponse == other.auth3xComplexLoungeResponse;

  @override
  int get hashCode =>
      connectDetails.hashCode ^
      auth4xPerformComplexLoungeResponse.hashCode ^
      auth3xComplexLoungeResponse.hashCode;

  @override
  String toString() {
    return 'LoungeConnectAndAuthDetails{'
        'connectDetails: $connectDetails, '
        'auth4xPerformComplexLoungeResponse: $auth4xPerformComplexLoungeResponse, '
        'auth3xComplexLoungeResponse: $auth3xComplexLoungeResponse'
        '}';
  }
}

class LoungeConnectDetails {
  final bool isSocketError;
  final bool isSocketTimeout;
  final bool isLoungeNotSentRequiredDataAndTimeoutReached;

  LoungeVersion get loungeVersion {
    if (backendMode == null) {
      return null;
    }

    switch (backendMode) {
      case LoungeBackendMode.private:
        return privatePart.loungeVersion;
        break;
      case LoungeBackendMode.public:
        return publicPart.loungeVersion;
        break;
    }

    throw "Invalid backendMode $backendMode";
  }

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
    if (backendMode == null) {
      return false;
    }

    if (isPublicMode) {
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

class Auth4xPerformComplexLoungeResponse extends LoungeComplexResponse {
  final Auth4xSuccessComplexLoungeResponse auth4xSuccessComplexLoungeResponse;
  final bool authFailedReceived;
  final bool loungeNotSentRequiredDataAndTimeoutReached;

  bool get isSuccess => auth4xSuccessComplexLoungeResponse != null;

  bool get isFail =>
      authFailedReceived == true ||
      loungeNotSentRequiredDataAndTimeoutReached == true;

  @override
  List<dynamic> get optionalFields => [];

  @override
  List<dynamic> get requiredFields => throw "Unsupported";

  @override
  bool get isRequiredFieldsExist =>
      auth4xSuccessComplexLoungeResponse?.isRequiredFieldsExist == true ||
      authFailedReceived == true;

  Auth4xPerformComplexLoungeResponse._private({
    @required this.auth4xSuccessComplexLoungeResponse,
    @required this.authFailedReceived,
    @required this.loungeNotSentRequiredDataAndTimeoutReached,
  });

  Auth4xPerformComplexLoungeResponse.response({
    @required
        Auth4xSuccessComplexLoungeResponse auth4xSuccessComplexLoungeResponse,
    @required bool authFailedReceived,
  }) : this._private(
          auth4xSuccessComplexLoungeResponse:
              auth4xSuccessComplexLoungeResponse,
          authFailedReceived: authFailedReceived,
          loungeNotSentRequiredDataAndTimeoutReached: false,
        );

  Auth4xPerformComplexLoungeResponse.loungeNotSentRequiredDataAndTimeoutReached()
      : this._private(
          auth4xSuccessComplexLoungeResponse: null,
          authFailedReceived: null,
          loungeNotSentRequiredDataAndTimeoutReached: true,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Auth4xPerformComplexLoungeResponse &&
          runtimeType == other.runtimeType &&
          auth4xSuccessComplexLoungeResponse ==
              other.auth4xSuccessComplexLoungeResponse &&
          authFailedReceived == other.authFailedReceived;

  @override
  int get hashCode =>
      auth4xSuccessComplexLoungeResponse.hashCode ^ authFailedReceived.hashCode;

  @override
  String toString() {
    return 'Auth4xPerformComplexLoungeResponse{'
        'authSuccessComplexLoungeResponse: $auth4xSuccessComplexLoungeResponse, '
        'authFailedReceived: $authFailedReceived'
        '}';
  }
}

class Auth3xComplexLoungeResponse extends LoungeComplexResponse {
  final Authorized3xComplexLoungeResponse authorized3xComplexLoungeResponse;
  final Auth3xLoungeResponseBody auth3xLoungeResponseBody;
  final bool loungeNotSentRequiredDataAndTimeoutReached;

  bool get isSuccess => authorized3xComplexLoungeResponse != null || auth3xLoungeResponseBody.success == true;

  bool get isFail => !isSuccess;

  @override
  List<dynamic> get optionalFields => [];

  @override
  List<dynamic> get requiredFields => throw "Unsupported";

  @override
  bool get isRequiredFieldsExist {
    _logger.finest(() => "isRequiredFieldsExist "
        "authorized3xComplexLoungeResponse $authorized3xComplexLoungeResponse");
    _logger.finest(() => "isRequiredFieldsExist "
        "auth3xLoungeResponseBody $auth3xLoungeResponseBody");

    var result;

    if (authorized3xComplexLoungeResponse != null) {
      _logger.finest(() => "isRequiredFieldsExist "
          "authorized3xComplexLoungeResponse.isRequiredFieldsExist "
          "${authorized3xComplexLoungeResponse.isRequiredFieldsExist}");
      result = authorized3xComplexLoungeResponse.isRequiredFieldsExist == true;
    } else {
      if (auth3xLoungeResponseBody == null) {
        result = false;
      }

      if (auth3xLoungeResponseBody.success) {
        result =
            authorized3xComplexLoungeResponse?.isRequiredFieldsExist == true;
      } else {
        result = true;
      }
    }

    _logger.finest(() => "isRequiredFieldsExist "
        "result $result");

    return result;
  }

  Auth3xComplexLoungeResponse._private({
    @required this.authorized3xComplexLoungeResponse,
    @required this.auth3xLoungeResponseBody,
    @required this.loungeNotSentRequiredDataAndTimeoutReached,
  });

  Auth3xComplexLoungeResponse.response({
    @required
        Authorized3xComplexLoungeResponse authorized3xComplexLoungeResponse,
    @required Auth3xLoungeResponseBody auth3xLoungeResponseBody,
  }) : this._private(
          authorized3xComplexLoungeResponse: authorized3xComplexLoungeResponse,
          auth3xLoungeResponseBody: auth3xLoungeResponseBody,
          loungeNotSentRequiredDataAndTimeoutReached: false,
        );

  Auth3xComplexLoungeResponse.loungeNotSentRequiredDataAndTimeoutReached()
      : this._private(
          authorized3xComplexLoungeResponse: null,
          auth3xLoungeResponseBody: null,
          loungeNotSentRequiredDataAndTimeoutReached: true,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Auth3xComplexLoungeResponse &&
          runtimeType == other.runtimeType &&
          authorized3xComplexLoungeResponse ==
              other.authorized3xComplexLoungeResponse &&
          auth3xLoungeResponseBody == other.auth3xLoungeResponseBody &&
          loungeNotSentRequiredDataAndTimeoutReached ==
              other.loungeNotSentRequiredDataAndTimeoutReached;

  @override
  int get hashCode =>
      authorized3xComplexLoungeResponse.hashCode ^
      auth3xLoungeResponseBody.hashCode ^
      loungeNotSentRequiredDataAndTimeoutReached.hashCode;

  @override
  String toString() => 'Auth3xComplexLoungeResponse{'
      'authorizedComplexLoungeResponse: $authorized3xComplexLoungeResponse, '
      'authLoungeResponseBody: $auth3xLoungeResponseBody, '
      'loungeNotSentRequiredDataAndTimeoutReached: $loungeNotSentRequiredDataAndTimeoutReached'
      '}';
}

class Auth4xSuccessComplexLoungeResponse extends LoungeComplexResponse {
  final ConfigurationLoungeResponseBody configurationLoungeResponseBody;
  final InitLoungeResponseBody initLoungeResponseBody;
  final CommandsLoungeResponseBody commandsLoungeResponseBody;
  final PushIsSubscribedLoungeResponseBody pushIsSubscribedLoungeResponseBody;
  final bool authSuccessReceived;

  @override
  List<dynamic> get optionalFields => [
        commandsLoungeResponseBody,
        pushIsSubscribedLoungeResponseBody,
      ];

  @override
  List<dynamic> get requiredFields => [
        configurationLoungeResponseBody,
        initLoungeResponseBody,
        authSuccessReceived,
      ];

  Auth4xSuccessComplexLoungeResponse({
    @required this.configurationLoungeResponseBody,
    @required this.initLoungeResponseBody,
    @required this.commandsLoungeResponseBody,
    @required this.pushIsSubscribedLoungeResponseBody,
    @required this.authSuccessReceived,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Auth4xSuccessComplexLoungeResponse &&
          runtimeType == other.runtimeType &&
          configurationLoungeResponseBody ==
              other.configurationLoungeResponseBody &&
          initLoungeResponseBody == other.initLoungeResponseBody &&
          commandsLoungeResponseBody == other.commandsLoungeResponseBody &&
          authSuccessReceived == other.authSuccessReceived &&
          pushIsSubscribedLoungeResponseBody ==
              other.pushIsSubscribedLoungeResponseBody;

  @override
  int get hashCode =>
      configurationLoungeResponseBody.hashCode ^
      initLoungeResponseBody.hashCode ^
      commandsLoungeResponseBody.hashCode ^
      authSuccessReceived.hashCode ^
      pushIsSubscribedLoungeResponseBody.hashCode;

  @override
  String toString() {
    return 'Auth4xSuccessComplexLoungeResponse{'
        'configurationLoungeResponseBody: $configurationLoungeResponseBody, '
        'initLoungeResponseBody: $initLoungeResponseBody, '
        'commandsLoungeResponseBody: $commandsLoungeResponseBody, '
        'authSuccessReceived: $authSuccessReceived, '
        'pushIsSubscribedLoungeResponseBody: $pushIsSubscribedLoungeResponseBody'
        '}';
  }
}

class Authorized3xComplexLoungeResponse extends LoungeComplexResponse {
  final ConfigurationLoungeResponseBody configurationLoungeResponseBody;
  final InitLoungeResponseBody initLoungeResponseBody;
  final CommandsLoungeResponseBody commandsLoungeResponseBody;
  final bool authorizedReceived;

  @override
  List<dynamic> get optionalFields => [
        commandsLoungeResponseBody,
      ];

  @override
  List<dynamic> get requiredFields => [
        authorizedReceived,
        initLoungeResponseBody,
        configurationLoungeResponseBody,
      ];

  Authorized3xComplexLoungeResponse({
    @required this.configurationLoungeResponseBody,
    @required this.initLoungeResponseBody,
    @required this.commandsLoungeResponseBody,
    @required this.authorizedReceived,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authorized3xComplexLoungeResponse &&
          runtimeType == other.runtimeType &&
          configurationLoungeResponseBody ==
              other.configurationLoungeResponseBody &&
          initLoungeResponseBody == other.initLoungeResponseBody &&
          commandsLoungeResponseBody == other.commandsLoungeResponseBody &&
          authorizedReceived == other.authorizedReceived;

  @override
  int get hashCode =>
      configurationLoungeResponseBody.hashCode ^
      initLoungeResponseBody.hashCode ^
      commandsLoungeResponseBody.hashCode ^
      authorizedReceived.hashCode;

  @override
  String toString() {
    return 'Authorized3xComplexLoungeResponse{'
        'configurationLoungeResponseBody: $configurationLoungeResponseBody, '
        'initLoungeResponseBody: $initLoungeResponseBody, '
        'commandsLoungeResponseBody: $commandsLoungeResponseBody, '
        'authorizedReceived: $authorizedReceived'
        '}';
  }
}
