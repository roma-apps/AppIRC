import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:flutter_appirc/socket_io/instance/socket_io_instance_bloc.dart';
import 'package:flutter_appirc/socket_io/socket_io_model.dart';
import 'package:logging/logging.dart';

final _logger = Logger("lounge_backend_socket_api_wrapper_bloc.dart");

const _defaultTimeoutDuration = Duration(seconds: 5);
const _waitIntervalForOptionalDataAfterRequiredDataReceived =
    Duration(seconds: 1);
const _defaultCheckResultIntervalDuration = Duration(milliseconds: 500);

class ComplexLoungeResponseWaitConfig extends LoungeResponseWaitConfig {
  static const defaultValue = ComplexLoungeResponseWaitConfig();

  final Duration waitIntervalForOptionalDataAfterRequiredDataReceived;

  const ComplexLoungeResponseWaitConfig({
    Duration timeoutDuration = _defaultTimeoutDuration,
    Duration checkResultIntervalDuration = _defaultCheckResultIntervalDuration,
    this.waitIntervalForOptionalDataAfterRequiredDataReceived =
        _waitIntervalForOptionalDataAfterRequiredDataReceived,
  }) : super(
          timeoutDuration: timeoutDuration,
          checkResultIntervalDuration: checkResultIntervalDuration,
        );

  @override
  String toString() {
    return 'ComplexResponseWaitConfig{'
        'timeoutDuration: $timeoutDuration, '
        'checkResultIntervalDuration: $checkResultIntervalDuration, '
        'waitIntervalForOptionalDataAfterRequiredDataReceived:'
        ' $waitIntervalForOptionalDataAfterRequiredDataReceived'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexLoungeResponseWaitConfig &&
          runtimeType == other.runtimeType &&
          timeoutDuration == other.timeoutDuration &&
          checkResultIntervalDuration == other.checkResultIntervalDuration &&
          waitIntervalForOptionalDataAfterRequiredDataReceived ==
              other.waitIntervalForOptionalDataAfterRequiredDataReceived;

  @override
  int get hashCode =>
      timeoutDuration.hashCode ^
      checkResultIntervalDuration.hashCode ^
      waitIntervalForOptionalDataAfterRequiredDataReceived.hashCode;
}

class LoungeResponseWaitConfig {
  static const defaultValue = LoungeResponseWaitConfig();

  final Duration timeoutDuration;
  final Duration checkResultIntervalDuration;

  const LoungeResponseWaitConfig({
    this.timeoutDuration = _defaultTimeoutDuration,
    this.checkResultIntervalDuration = _defaultCheckResultIntervalDuration,
  });

  @override
  String toString() {
    return 'ComplexResponseWaitConfig{'
        'timeoutDuration: $timeoutDuration, '
        'checkResultIntervalDuration: $checkResultIntervalDuration, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexLoungeResponseWaitConfig &&
          runtimeType == other.runtimeType &&
          timeoutDuration == other.timeoutDuration &&
          checkResultIntervalDuration == other.checkResultIntervalDuration;

  @override
  int get hashCode =>
      timeoutDuration.hashCode ^ checkResultIntervalDuration.hashCode;
}

class LoungeBackendSocketIoApiWrapperBloc {
  final SocketIOInstanceBloc socketIOInstanceBloc;

  LoungeBackendSocketIoApiWrapperBloc({
    @required this.socketIOInstanceBloc,
  });

  bool checkIsComplexWaitFinished({
    @required LoungeComplexResponse complexResponse,
    @required startTime,
    ComplexLoungeResponseWaitConfig waitConfig =
        ComplexLoungeResponseWaitConfig.defaultValue,
  }) {

    _logger.finest(() => "checkIsComplexWaitFinished "
        "isRequiredFieldsExist ${complexResponse.isRequiredFieldsExist} "
        "isOptionalFieldsExist ${complexResponse.isOptionalFieldsExist}\n"
        "\t complexResponse $complexResponse"
    );

    if (complexResponse == null) {
      return false;
    }

    if (complexResponse.isAllFieldsExist) {
      // all data received
      return true;
    } else {
      DateTime now = DateTime.now();

      var diffTimeout = now.difference(startTime).abs();

      var timeoutReached = diffTimeout > waitConfig.timeoutDuration;
      if (timeoutReached) {
        return true;
      }

      if (complexResponse.isRequiredFieldsExist) {
        if (complexResponse.allRequiredDataReceivedTime != null) {
          var now = DateTime.now();
          var diffAllRequiredDataReceivedTimeDuration =
              now.difference(complexResponse.allRequiredDataReceivedTime).abs();

          var waitForOptionalDataReached =
              diffAllRequiredDataReceivedTimeDuration >
                  waitConfig
                      .waitIntervalForOptionalDataAfterRequiredDataReceived;
          var isPossibleToWaitMore = waitForOptionalDataReached;
          if (!isPossibleToWaitMore) {
            // required data received and not enough time to wait more
            return true;
          } else {
            // waiting for optional data not received yet
            return false;
          }
        } else {
          // wait more for optional data
          return false;
        }
      } else {
        // required data not received yet
        return false;
      }
    }
  }

  Future connect() => socketIOInstanceBloc.connect();

  Future<LoungeConnectDetails> connectAndWaitForResponse({
    ComplexLoungeResponseWaitConfig waitConfig =
        ComplexLoungeResponseWaitConfig.defaultValue,
  }) async {
    _logger.finest(() => "connectAndWaitForResponse");

    var disposableOwner = DisposableOwner();

    var startTime = DateTime.now();
    LoungeConnectDetailsPublicPart handledPublicPart;
    LoungeConnectDetailsPrivatePart handledPrivatePart;

    disposableOwner.addDisposable(
      disposable: listenLoungeConnectDetailsPublicPartComplexResponse(
        (publicPart) {
          handledPublicPart = publicPart;
          _logger.finest(() =>
              "connectAndWaitForResponse handledPublicPart $handledPublicPart");
        },
      ),
    );
    disposableOwner.addDisposable(
      disposable: listenLoungeConnectDetailsPrivatePartComplexResponse(
        (privatePart) {
          handledPrivatePart = privatePart;

          _logger.finest(() =>
              "connectAndWaitForResponse handledPrivatePart $handledPrivatePart");
        },
      ),
    );

    var connectionState =
        await socketIOInstanceBloc.connectAndWaitForConnectionResult(
      timeoutDuration: waitConfig.timeoutDuration,
      checkResultIntervalDuration: waitConfig.checkResultIntervalDuration,
    );

    var result;

    if (connectionState.isTimeout) {
      result = LoungeConnectDetails.socketTimeout();
    }
    if (connectionState.isError) {
      result = LoungeConnectDetails.socketError();
    }

    var resultChecker = () {
      if (handledPrivatePart != null) {
        var isFinished = checkIsComplexWaitFinished(
          startTime: startTime,
          complexResponse: handledPrivatePart,
          waitConfig: waitConfig,
        );

        if (isFinished) {
          _logger.finest(() => "connectAndWaitForResponse finished private");
          return LoungeConnectDetails.private(
            privatePart: handledPrivatePart,
          );
        } else {
          return null;
        }
      } else if (handledPublicPart != null) {
        var isFinished = checkIsComplexWaitFinished(
          startTime: startTime,
          complexResponse: handledPublicPart,
          waitConfig: waitConfig,
        );

        if (isFinished) {
          _logger.finest(() => "connectAndWaitForResponse finished public");
          return LoungeConnectDetails.public(
            publicPart: handledPublicPart,
          );
        } else {
          return null;
        }
      } else {
        return null;
      }
    };

    while (result == null) {
      await Future.delayed(_defaultCheckResultIntervalDuration);
      DateTime now = DateTime.now();

      var diffTimeout = now.difference(startTime).abs();

      var timeoutReached = diffTimeout > waitConfig.timeoutDuration;
      if (timeoutReached) {
        result =
            LoungeConnectDetails.loungeNotSentRequiredDataAndTimeoutReached();
      }
      result = resultChecker();
    }

    await disposableOwner.dispose();

    return result;
  }

  Future sendNetworkNew({
    @required String join,
    @required String host,
    @required String name,
    @required String nick,
    @required String port,
    @required String realname,
    @required String password,
    @required String rejectUnauthorized,
    @required String tls,
    @required String username,
    @required String commands,
  }) =>
      sendRequest(
        NetworkNewLoungeJsonRequest(
          join: join,
          host: host,
          name: name,
          nick: nick,
          port: port,
          realname: realname,
          password: password,
          rejectUnauthorized: rejectUnauthorized,
          tls: tls,
          username: username,
          commands: commands,
        ),
      );

  Future sendNetworkGet({
    @required String uuid,
  }) =>
      sendRequest(
        LoungeNetworkGetRawRequest(
          uuid: uuid,
        ),
      );

  Future<NetworkLoungeResponseBodyPart> sendNetworkGetAndWaitForResponse({
    @required String uuid,
  }) {
    NetworkLoungeResponseBodyPart handled;

    return socketIOInstanceBloc.doSomethingAndWaitForResult(
      listenDisposable: listenForNetworkInfo(
        (NetworkLoungeResponseBodyPart data) => handled = data,
      ),
      action: () => sendNetworkGet(
        uuid: uuid,
      ),
      resultChecker: () async => handled,
    );
  }

  Future sendNetworkEdit({
    @required String uuid,
    @required String host,
    @required String name,
    @required String nick,
    @required String port,
    @required String realname,
    @required String password,
    @required String rejectUnauthorized,
    @required String tls,
    @required String username,
    @required String commands,
  }) =>
      sendRequest(
        NetworkEditLoungeJsonRequest(
          uuid: uuid,
          host: host,
          name: name,
          nick: nick,
          port: port,
          realname: realname,
          password: password,
          rejectUnauthorized: rejectUnauthorized,
          tls: tls,
          username: username,
          commands: commands,
        ),
      );

  Future sendAuth4xPerform({
    @required String user,
    @required String password,
    @required String token,
    @required int lastMessageRemoteId,
    @required int openChannelRemoteId,
    @required bool hasConfig,
  }) =>
      sendRequest(
        Auth4xPerformLoungeJsonRequest(
          user: user,
          password: password,
          token: token,
          lastMessageRemoteId: lastMessageRemoteId,
          openChannelRemoteId: openChannelRemoteId,
          hasConfig: hasConfig,
        ),
      );

  Future sendAuth3x({
    @required String user,
    @required String password,
    @required String token,
    @required int lastMessageRemoteId,
    @required int openChannelRemoteId,
  }) =>
      sendRequest(
        Auth3xLoungeJsonRequest(
          user: user,
          password: password,
          token: token,
          lastMessageRemoteId: lastMessageRemoteId,
          openChannelRemoteId: openChannelRemoteId,
        ),
      );

  Future<Auth3xComplexLoungeResponse> sendAuth3xAndWaitForResult({
    @required String user,
    @required String password,
    @required String token,
    @required int lastMessageRemoteId,
    @required int openChannelRemoteId,
    ComplexLoungeResponseWaitConfig waitConfig =
        ComplexLoungeResponseWaitConfig.defaultValue,
  }) async {
    _logger.finest(() => "sendAuth3xAndWaitForResult start");
    Auth3xComplexLoungeResponse result;

    var disposableOwner = DisposableOwner();

    var startTime = DateTime.now();

    disposableOwner.addDisposable(
      disposable: listenForAuth3xComplexLoungeResponse(
        (Auth3xComplexLoungeResponse auth3xComplexLoungeResponse) {
          _logger.finest(() => "sendAuth3xAndWaitForResult "
              "auth3xComplexLoungeResponse $auth3xComplexLoungeResponse");
          result = auth3xComplexLoungeResponse;
        },
      ),
    );

    await sendRequest(
      Auth3xLoungeJsonRequest(
        user: user,
        password: password,
        token: token,
        lastMessageRemoteId: lastMessageRemoteId,
        openChannelRemoteId: openChannelRemoteId,
      ),
    );

    while (result == null) {
      await Future.delayed(_defaultCheckResultIntervalDuration);
      DateTime now = DateTime.now();

      var diffTimeout = now.difference(startTime).abs();

      var timeoutReached = diffTimeout > waitConfig.timeoutDuration;
      if (timeoutReached) {
        result = Auth3xComplexLoungeResponse
            .loungeNotSentRequiredDataAndTimeoutReached();
      }
    }

    await disposableOwner.dispose();

    return result;
  }

  Future<Auth4xPerformComplexLoungeResponse> sendAuth4xPerformAndWaitForResult({
    @required String user,
    @required String password,
    @required String token,
    @required int lastMessageRemoteId,
    @required int openChannelRemoteId,
    @required bool hasConfig,
    ComplexLoungeResponseWaitConfig waitConfig =
        ComplexLoungeResponseWaitConfig.defaultValue,
  }) async {
    Auth4xPerformComplexLoungeResponse result;

    var disposableOwner = DisposableOwner();

    var startTime = DateTime.now();

    disposableOwner.addDisposable(
      disposable: listenForAuth4xPerformComplexLoungeResponse(
        (Auth4xPerformComplexLoungeResponse
            auth4xPerformComplexLoungeResponse) {
          result = auth4xPerformComplexLoungeResponse;
        },
      ),
    );

    await sendRequest(
      Auth4xPerformLoungeJsonRequest(
        user: user,
        password: password,
        token: token,
        lastMessageRemoteId: lastMessageRemoteId,
        openChannelRemoteId: openChannelRemoteId,
        hasConfig: hasConfig,
      ),
    );

    while (result == null) {
      await Future.delayed(_defaultCheckResultIntervalDuration);
      DateTime now = DateTime.now();

      var diffTimeout = now.difference(startTime).abs();

      var timeoutReached = diffTimeout > waitConfig.timeoutDuration;
      if (timeoutReached) {
        result = Auth4xPerformComplexLoungeResponse
            .loungeNotSentRequiredDataAndTimeoutReached();
      }
    }

    await disposableOwner.dispose();

    return result;
  }

  // not available in original lounge code
  Future sendSignUp({
    @required String user,
    @required String password,
  }) =>
      sendRequest(
        SignUpLoungeJsonRequest(
          user: user,
          password: password,
        ),
      );

  Future<SignedUpLoungeResponseBody> sendSignUpAndWaitForResult({
    @required String user,
    @required String password,
  }) {
    SignedUpLoungeResponseBody handled;

    return socketIOInstanceBloc.doSomethingAndWaitForResult(
      listenDisposable: listenForSignedUp(
        (SignedUpLoungeResponseBody data) => handled = data,
      ),
      action: () => sendSignUp(
        user: user,
        password: password,
      ),
      resultChecker: () async => handled,
    );
  }

  Future sendNames({
    @required int targetChannelRemoteId,
  }) =>
      sendRequest(
        NamesLoungeJsonRequest(
          targetChannelRemoteId: targetChannelRemoteId,
        ),
      );

  Future sendMsgPreviewToggle({
    @required int targetChannelRemoteId,
    @required int messageRemoteId,
    @required String link,
    @required bool shown,
  }) =>
      sendRequest(
        MsgPreviewToggleLoungeJsonRequest(
          targetChannelRemoteId: targetChannelRemoteId,
          messageRemoteId: messageRemoteId,
          link: link,
          shown: shown,
        ),
      );

  Future sendMore({
    @required int targetChannelRemoteId,
    @required int lastMessageRemoteId,
  }) =>
      sendRequest(
        MoreLoungeJsonRequest(
          targetChannelRemoteId: targetChannelRemoteId,
          lastMessageRemoteId: lastMessageRemoteId,
        ),
      );

  Future sendInput({
    @required int targetChannelRemoteId,
    @required String text,
  }) =>
      sendRequest(
        InputLoungeJsonRequest(
          targetChannelRemoteId: targetChannelRemoteId,
          text: text,
        ),
      );

  // not available in original lounge code
  Future sendPushFCMToken({
    @required String fcmToken,
  }) =>
      sendRequest(
        PushFCMTokenLoungeJsonRequest(
          fcmToken: fcmToken,
        ),
      );

  Future sendChannelOpened({
    @required int channelRemoteId,
  }) =>
      sendRequest(
        ChannelOpenedLoungeRawRequest(
          channelRemoteId: channelRemoteId,
        ),
      );

  Future sendUploadAuth() => sendRequest(
        const UploadAuthLoungeEmptyRequest(),
      );

  Future sendSignOut() => sendRequest(
        const SignOutLoungeEmptyRequest(),
      );

  Future sendRequest(LoungeRequest request) {
    var socketIOCommand = request.toSocketIOCommand();
    _logger.fine(
      () => "_sendCommand $request \n"
          "\t socketIOCommand $socketIOCommand",
    );
    return socketIOInstanceBloc.emit(socketIOCommand);
  }

  IDisposable listenLoungeConnectDetailsPublicPartComplexResponse(
      Function(LoungeConnectDetailsPublicPart publicPart) listener) {
    Auth4xSuccessComplexLoungeResponse handledAuthSuccessComplexLoungeResponse;
    Authorized3xComplexLoungeResponse handledAuthorizedComplexLoungeResponse;

    var listenerCallback = () {
      listener(
        LoungeConnectDetailsPublicPart(
          auth4xSuccessComplexLoungeResponse:
              handledAuthSuccessComplexLoungeResponse,
          authorized3xComplexLoungeResponse:
              handledAuthorizedComplexLoungeResponse,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForAuth4xSuccessComplexAuthResponse(
        (Auth4xSuccessComplexLoungeResponse
            auth4xSuccessComplexLoungeResponse) {
          handledAuthSuccessComplexLoungeResponse =
              auth4xSuccessComplexLoungeResponse;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForAuthorized3xComplexLoungeResponse(
        (Authorized3xComplexLoungeResponse authorized3xComplexLoungeResponse) {
          handledAuthorizedComplexLoungeResponse =
              authorized3xComplexLoungeResponse;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForAuth4xPerformComplexLoungeResponse(
      Function(
              Auth4xPerformComplexLoungeResponse
                  authPerformComplexLoungeResponse)
          listener) {
    Auth4xSuccessComplexLoungeResponse
        handledAuth4xSuccessComplexLoungeResponse;
    bool authFailedReceived = false;

    DateTime startTime = DateTime.now();

    var listenerCallback = () {
      var response = Auth4xPerformComplexLoungeResponse.response(
        auth4xSuccessComplexLoungeResponse:
            handledAuth4xSuccessComplexLoungeResponse,
        authFailedReceived: authFailedReceived,
      );

      var isFinished = checkIsComplexWaitFinished(
        complexResponse: response,
        startTime: startTime,
      );

      if (isFinished) {
        listener(response);
      }
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForAuth4xSuccessComplexAuthResponse(
        (Auth4xSuccessComplexLoungeResponse authSuccessComplexLoungeResponse) {
          handledAuth4xSuccessComplexLoungeResponse =
              authSuccessComplexLoungeResponse;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForAuth4xFailed(
        () {
          authFailedReceived = true;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForAuth3xComplexLoungeResponse(
      Function(Auth3xComplexLoungeResponse auth3xComplexLoungeResponse)
          listener) {

    _logger.finest(() => "listenForAuth3xComplexLoungeResponse start");
    Auth3xLoungeResponseBody handledAuth3xLoungeResponseBody;
    Authorized3xComplexLoungeResponse handledAuthorized3xComplexLoungeResponse;

    DateTime startTime = DateTime.now();

    var listenerCallback = () {
      var response = Auth3xComplexLoungeResponse.response(
        auth3xLoungeResponseBody: handledAuth3xLoungeResponseBody,
        authorized3xComplexLoungeResponse:
            handledAuthorized3xComplexLoungeResponse,
      );

      var isFinished = checkIsComplexWaitFinished(
        complexResponse: response,
        startTime: startTime,
      );

      if (isFinished) {
        listener(response);
      }
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForAuth3x(
        (Auth3xLoungeResponseBody auth3xLoungeResponseBody) {
          _logger.finest(() => "listenForAuth3xComplexLoungeResponse "
              "auth3xLoungeResponseBody $auth3xLoungeResponseBody");
          handledAuth3xLoungeResponseBody = auth3xLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForAuthorized3xComplexLoungeResponse(
        (Authorized3xComplexLoungeResponse authorized3xComplexLoungeResponse) {
          _logger.finest(() => "listenForAuth3xComplexLoungeResponse "
              "authorized3xComplexLoungeResponse $authorized3xComplexLoungeResponse");
          handledAuthorized3xComplexLoungeResponse =
              authorized3xComplexLoungeResponse;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForAuth4xSuccessComplexAuthResponse(
      Function(
              Auth4xSuccessComplexLoungeResponse
                  auth4xSuccessComplexLoungeResponse)
          listener) {
    InitLoungeResponseBody handledInitLoungeResponseBody;
    ConfigurationLoungeResponseBody handledConfigurationLoungeResponseBody;
    PushIsSubscribedLoungeResponseBody
        handledPushIsSubscribedLoungeResponseBody;
    CommandsLoungeResponseBody handledCommandsLoungeResponseBody;
    bool authSuccessReceived;

    var listenerCallback = () {
      listener(
        Auth4xSuccessComplexLoungeResponse(
          initLoungeResponseBody: handledInitLoungeResponseBody,
          configurationLoungeResponseBody:
              handledConfigurationLoungeResponseBody,
          pushIsSubscribedLoungeResponseBody:
              handledPushIsSubscribedLoungeResponseBody,
          commandsLoungeResponseBody: handledCommandsLoungeResponseBody,
          authSuccessReceived: authSuccessReceived,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForAuth4xSuccess(
        () {
          authSuccessReceived = true;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForInit(
        (InitLoungeResponseBody initLoungeResponseBody) {
          handledInitLoungeResponseBody = initLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForConfiguration(
        (ConfigurationLoungeResponseBody configurationLoungeResponseBody) {
          handledConfigurationLoungeResponseBody =
              configurationLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForPushIsSubscribed(
        (PushIsSubscribedLoungeResponseBody
            pushIsSubscribedLoungeResponseBody) {
          handledPushIsSubscribedLoungeResponseBody =
              pushIsSubscribedLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForCommands(
        (CommandsLoungeResponseBody commandsLoungeResponseBody) {
          handledCommandsLoungeResponseBody = commandsLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForAuthorized3xComplexLoungeResponse(
      Function(
              Authorized3xComplexLoungeResponse
                  authorized3xComplexLoungeResponse)
          listener) {
    InitLoungeResponseBody handledInitLoungeResponseBody;
    ConfigurationLoungeResponseBody handledConfigurationLoungeResponseBody;
    CommandsLoungeResponseBody handledCommandsLoungeResponseBody;
    bool authorizedReceived;

    var listenerCallback = () {
      listener(
        Authorized3xComplexLoungeResponse(
          initLoungeResponseBody: handledInitLoungeResponseBody,
          configurationLoungeResponseBody:
              handledConfigurationLoungeResponseBody,
          commandsLoungeResponseBody: handledCommandsLoungeResponseBody,
          authorizedReceived: authorizedReceived,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForAuthorized3x(
        () {
          authorizedReceived = true;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForInit(
        (InitLoungeResponseBody initLoungeResponseBody) {
          handledInitLoungeResponseBody = initLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForConfiguration(
        (ConfigurationLoungeResponseBody configurationLoungeResponseBody) {
          handledConfigurationLoungeResponseBody =
              configurationLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForCommands(
        (CommandsLoungeResponseBody commandsLoungeResponseBody) {
          handledCommandsLoungeResponseBody = commandsLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenLoungeConnectDetailsPrivatePartComplexResponse(
      Function(LoungeConnectDetailsPrivatePart privatePart) listener) {
    SignUpAvailableLoungeResponseBody handledSignUpAvailableLoungeResponseBody;
    Auth4xStartLoungeResponseBody handledAuth4xStartLoungeResponseBody;
    Auth3xLoungeResponseBody handledAuth3xLoungeResponseBody;

    var listenerCallback = () {
      listener(
        LoungeConnectDetailsPrivatePart(
          signUpAvailableResponseBody: handledSignUpAvailableLoungeResponseBody,
          auth4xStartLoungeResponseBody: handledAuth4xStartLoungeResponseBody,
          auth3xLoungeResponseBody: handledAuth3xLoungeResponseBody,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForSignUpAvailable(
        (SignUpAvailableLoungeResponseBody signUpAvailableResponseBody) {
          _logger.finest(() =>
              "listenLoungeConnectDetailsPrivatePartComplexResponse "
                  "signUpAvailableResponseBody $signUpAvailableResponseBody");
          handledSignUpAvailableLoungeResponseBody =
              signUpAvailableResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForAuth4xStart(
        (Auth4xStartLoungeResponseBody auth4xStartLoungeResponseBody) {
          _logger.finest(() =>
          "listenLoungeConnectDetailsPrivatePartComplexResponse "
              "auth4xStartLoungeResponseBody $auth4xStartLoungeResponseBody");
          handledAuth4xStartLoungeResponseBody = auth4xStartLoungeResponseBody;
          listenerCallback();
        },
      ),
    );
    disposableOwner.addDisposable(
      disposable: listenForAuth3x(
        (Auth3xLoungeResponseBody auth3xLoungeResponseBody) {
          _logger.finest(() =>
          "listenLoungeConnectDetailsPrivatePartComplexResponse "
              "auth3xLoungeResponseBody $auth3xLoungeResponseBody");
          handledAuth3xLoungeResponseBody = auth3xLoungeResponseBody;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForSignOut(Function(SignOutLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: SignOutLoungeResponseBody.eventName,
        listener: (raw) => listener(
          SignOutLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForUploadAuth(
          Function(UploadAuthLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: UploadAuthLoungeResponseBody.eventName,
        listener: (raw) => listener(
          UploadAuthLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForCommands(
          Function(CommandsLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: CommandsLoungeResponseBody.eventName,
        listener: (raw) => listener(
          CommandsLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForMessagePreviewToggle(
          Function(MessagePreviewToggleLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: MessagePreviewToggleLoungeResponseBody.eventName,
        listener: (json) => listener(
          MessagePreviewToggleLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForMore(Function(MoreLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: MoreLoungeResponseBody.eventName,
        listener: (json) => listener(
          MoreLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForChangelog(
          Function(ChangelogLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: ChangelogLoungeResponseBody.eventName,
        listener: (json) => listener(
          ChangelogLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForSyncSort(
          Function(SyncSortLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: SyncSortLoungeResponseBody.eventName,
        listener: (json) => listener(
          SyncSortLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForSettingNew(
          Function(SettingsNewLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: SettingsNewLoungeResponseBody.eventName,
        listener: (json) => listener(
          SettingsNewLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForSettingsAll(
          Function(SettingsAllLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: SettingsAllLoungeResponseBody.eventName,
        listener: (json) => listener(
          SettingsAllLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForSessionsList(
          Function(SessionsListLoungeResponseBodyPart) listener) =>
      listenJsonEvent(
        eventName: SessionsListLoungeResponseBodyPart.eventName,
        listener: (json) => listener(
          SessionsListLoungeResponseBodyPart.fromJson(json),
        ),
      );

  IDisposable listenForMsg(Function(MsgLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: MsgLoungeResponseBody.eventName,
        listener: (json) => listener(
          MsgLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForMsgSpecial(
          Function(MsgSpecialLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: MsgSpecialLoungeResponseBody.eventName,
        listener: (json) => listener(
          MsgSpecialLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForConfiguration(
          Function(ConfigurationLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: ConfigurationLoungeResponseBody.eventName,
        listener: (json) => listener(
          ConfigurationLoungeResponseBody.fromJson(json),
        ),
      );

  // not supported on original TheLounge
  IDisposable listenForSignedUp(
          Function(SignedUpLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: SignedUpLoungeResponseBody.eventName,
        listener: (json) => listener(
          SignedUpLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForJoin(Function(JoinLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: JoinLoungeResponseBody.eventName,
        listener: (json) => listener(
          JoinLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForPart(Function(PartLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: PartLoungeResponseBody.eventName,
        listener: (json) => listener(
          PartLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForQuit(Function(QuitLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: QuitLoungeResponseBody.eventName,
        listener: (json) => listener(
          QuitLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForNetworkStatus(
          Function(NetworkStatusLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: NetworkStatusLoungeResponseBody.eventName,
        listener: (json) => listener(
          NetworkStatusLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForNetworkOptions(
          Function(NetworkOptionsLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: NetworkOptionsLoungeResponseBody.eventName,
        listener: (json) => listener(
          NetworkOptionsLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForChannelState(
          Function(ChannelStateLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: ChannelStateLoungeResponseBody.eventName,
        listener: (json) => listener(
          ChannelStateLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForUsers(Function(UsersLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: UsersLoungeResponseBody.eventName,
        listener: (json) => listener(
          UsersLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForNick(Function(NickLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: NickLoungeResponseBody.eventName,
        listener: (json) => listener(
          NickLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForMsgPreview(
          Function(MsgPreviewLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: MsgPreviewLoungeResponseBody.eventName,
        listener: (json) => listener(
          MsgPreviewLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForInit(Function(InitLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: InitLoungeResponseBody.eventName,
        listener: (json) => listener(
          InitLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForNames(Function(NamesLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: NamesLoungeResponseBody.eventName,
        listener: (json) => listener(
          NamesLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForTopic(Function(TopicLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: TopicLoungeResponseBody.eventName,
        listener: (json) => listener(
          TopicLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForNetwork(Function(NetworkLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: NetworkLoungeResponseBody.eventName,
        listener: (json) => listener(
          NetworkLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForNetworkInfo(
          Function(NetworkLoungeResponseBodyPart) listener) =>
      listenJsonEvent(
        eventName: LoungeResponseEventNames.networkInfo,
        listener: (json) => listener(
          NetworkLoungeResponseBodyPart.fromJson(json),
        ),
      );

  IDisposable listenForSignUpAvailable(
          Function(SignUpAvailableLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: LoungeResponseEventNames.signUpAvailable,
        listener: (raw) => listener(
          SignUpAvailableLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForAuth3x(Function(Auth3xLoungeResponseBody) listener) =>
      listenJsonEvent(
        eventName: Auth3xLoungeResponseBody.eventName,
        listener: (json) => listener(
          Auth3xLoungeResponseBody.fromJson(json),
        ),
      );

  IDisposable listenForAuth4xStart(
          Function(Auth4xStartLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: Auth4xStartLoungeResponseBody.eventName,
        listener: (raw) => listener(
          Auth4xStartLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForAuth4xSuccess(Function() listener) => listenEmptyEvent(
        eventName: LoungeResponseEventNames.authSuccess,
        listener: () => listener(),
      );

  IDisposable listenForAuthorized3x(Function() listener) => listenEmptyEvent(
        eventName: LoungeResponseEventNames.authorized,
        listener: () => listener(),
      );

  IDisposable listenForAuth4xFailed(Function() listener) => listenEmptyEvent(
        eventName: LoungeResponseEventNames.authFailed,
        listener: () => listener(),
      );

  IDisposable listenForPushIsSubscribed(
          Function(PushIsSubscribedLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: PushIsSubscribedLoungeResponseBody.eventName,
        listener: (raw) => listener(
          PushIsSubscribedLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenJsonEvent({
    @required String eventName,
    @required Function(dynamic jsonData) listener,
  }) =>
      socketIOInstanceBloc.listen(
        eventName,
        (data) {
          listener(
            _preProcessRawDataEncodeDecodeJson(
              raw: data,
            ),
          );
        },
      );

  IDisposable listenRawEvent({
    @required String eventName,
    @required Function(dynamic raw) listener,
  }) =>
      socketIOInstanceBloc.listen(
        eventName,
        (data) {
          listener(data);
        },
      );

  IDisposable listenEmptyEvent({
    @required String eventName,
    @required Function() listener,
  }) =>
      socketIOInstanceBloc.listen(
        eventName,
        (data) {
          listener();
        },
      );

// dynamic because it is json entity, so maybe List or Map
  static dynamic _preProcessRawDataEncodeDecodeJson({
    @required raw,
    bool isJsonData = true,
  }) {
    // Hack for strange bug on ios
    // Flutter app throw exception which is not possible to catch
    // if use raw data without re-encoding
    // TODO: remove when bug will be fixed in socketio/json libraries
    var newRaw = raw;
    if (isJsonData && Platform.isIOS) {
      if (raw is Map) {
        var jsonData = json.encode(raw);
        newRaw = json.decode(jsonData);
      }
    }

    _logger.finest(
        () => "_preProcessRawData json = $isJsonData converted $newRaw");
    return newRaw;
  }
}

extension LoungeRequestSocketIoExtension on LoungeRequest {
  SocketIOCommand toSocketIOCommand() {
    if (this is LoungeJsonRequest) {
      LoungeJsonRequest loungeJsonRequest = this;
      return SocketIOCommand(
        eventName: eventName,
        parameters: [
          loungeJsonRequest.toJson(),
        ],
      );
    } else if (this is LoungeRawRequest) {
      LoungeRawRequest loungeRawRequest = this;
      return SocketIOCommand(
        eventName: eventName,
        parameters: [
          loungeRawRequest.body,
        ],
      );
    } else if (this is LoungeEmptyRequest) {
      return SocketIOCommand(
        eventName: eventName,
        parameters: [],
      );
    } else {
      throw "Unsupported type $this";
    }
  }
}
