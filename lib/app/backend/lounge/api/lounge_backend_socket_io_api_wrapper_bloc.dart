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
      },
    ));
    disposableOwner.addDisposable(
        disposable: listenLoungeConnectDetailsPrivatePartComplexResponse(
      (privatePart) {
        handledPrivatePart = privatePart;
      },
    ));

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

  Future sendAuthPerform({
    @required String user,
    @required String password,
    @required String token,
    @required int lastMessageRemoteId,
    @required int openChannelRemoteId,
    @required bool hasConfig,
  }) =>
      sendRequest(
        AuthPerformLoungeJsonRequest(
          user: user,
          password: password,
          token: token,
          lastMessageRemoteId: lastMessageRemoteId,
          openChannelRemoteId: openChannelRemoteId,
          hasConfig: hasConfig,
        ),
      );

  Future<AuthPerformComplexLoungeResponse> sendAuthPerformAndWaitForResult({
    @required String user,
    @required String password,
    @required String token,
    @required int lastMessageRemoteId,
    @required int openChannelRemoteId,
    @required bool hasConfig,
    ComplexLoungeResponseWaitConfig waitConfig =
        ComplexLoungeResponseWaitConfig.defaultValue,
  }) async {
    AuthPerformComplexLoungeResponse result;

    var disposableOwner = DisposableOwner();

    var startTime = DateTime.now();

    disposableOwner.addDisposable(
      disposable: listenForAuthPerformComplexLoungeResponse(
        (AuthPerformComplexLoungeResponse authPerformComplexLoungeResponse) {
          result = authPerformComplexLoungeResponse;
        },
      ),
    );

    await sendRequest(
      AuthPerformLoungeJsonRequest(
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
        result = AuthPerformComplexLoungeResponse
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
    AuthSuccessComplexLoungeResponse handledAuthSuccessComplexLoungeResponse;

    var listenerCallback = () {
      listener(
        LoungeConnectDetailsPublicPart(
          authSuccessComplexLoungeResponse:
              handledAuthSuccessComplexLoungeResponse,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForAuthSuccessComplexAuthResponse(
        (AuthSuccessComplexLoungeResponse authSuccessComplexLoungeResponse) {
          handledAuthSuccessComplexLoungeResponse =
              authSuccessComplexLoungeResponse;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForAuthPerformComplexLoungeResponse(
      Function(
              AuthPerformComplexLoungeResponse authPerformComplexLoungeResponse)
          listener) {
    AuthSuccessComplexLoungeResponse handledAuthSuccessComplexLoungeResponse;
    bool authFailedReceived = false;

    DateTime startTime = DateTime.now();

    var listenerCallback = () {
      var response = AuthPerformComplexLoungeResponse.response(
        authSuccessComplexLoungeResponse:
            handledAuthSuccessComplexLoungeResponse,
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
      disposable: listenForAuthSuccessComplexAuthResponse(
        (AuthSuccessComplexLoungeResponse authSuccessComplexLoungeResponse) {
          handledAuthSuccessComplexLoungeResponse =
              authSuccessComplexLoungeResponse;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForAuthFailed(
        () {
          authFailedReceived = true;
          listenerCallback();
        },
      ),
    );

    return disposableOwner;
  }

  IDisposable listenForAuthSuccessComplexAuthResponse(
      Function(
              AuthSuccessComplexLoungeResponse authSuccessComplexLoungeResponse)
          listener) {
    InitLoungeResponseBody handledInitLoungeResponseBody;
    ConfigurationLoungeResponseBody handledConfigurationLoungeResponseBody;
    PushIsSubscribedLoungeResponseBody
        handledPushIsSubscribedLoungeResponseBody;
    CommandsLoungeResponseBody handledCommandsLoungeResponseBody;

    var listenerCallback = () {
      listener(
        AuthSuccessComplexLoungeResponse(
          initLoungeResponseBody: handledInitLoungeResponseBody,
          configurationLoungeResponseBody:
              handledConfigurationLoungeResponseBody,
          pushIsSubscribedLoungeResponseBody:
              handledPushIsSubscribedLoungeResponseBody,
          commandsLoungeResponseBody: handledCommandsLoungeResponseBody,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

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

  IDisposable listenLoungeConnectDetailsPrivatePartComplexResponse(
      Function(LoungeConnectDetailsPrivatePart privatePart) listener) {
    SignUpAvailableLoungeResponseBody handledSignUpAvailableLoungeResponseBody;
    AuthStartLoungeResponseBody handledAuthStartLoungeResponseBody;

    var listenerCallback = () {
      listener(
        LoungeConnectDetailsPrivatePart(
          signUpAvailableResponseBody: handledSignUpAvailableLoungeResponseBody,
          authStartLoungeResponseBody: handledAuthStartLoungeResponseBody,
        ),
      );
    };

    var disposableOwner = DisposableOwner();

    disposableOwner.addDisposable(
      disposable: listenForSignUpAvailable(
        (SignUpAvailableLoungeResponseBody signUpAvailableResponseBody) {
          handledSignUpAvailableLoungeResponseBody =
              signUpAvailableResponseBody;
          listenerCallback();
        },
      ),
    );

    disposableOwner.addDisposable(
      disposable: listenForAuthStart(
        (AuthStartLoungeResponseBody authStartLoungeResponseBody) {
          handledAuthStartLoungeResponseBody = authStartLoungeResponseBody;
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

  IDisposable listenForSignUpAvailable(
          Function(SignUpAvailableLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: LoungeResponseEventNames.signUpAvailable,
        listener: (raw) => listener(
          SignUpAvailableLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForAuthStart(
          Function(AuthStartLoungeResponseBody) listener) =>
      listenRawEvent(
        eventName: AuthStartLoungeResponseBody.eventName,
        listener: (raw) => listener(
          AuthStartLoungeResponseBody.fromRaw(raw),
        ),
      );

  IDisposable listenForAuthSuccess(Function() listener) => listenEmptyEvent(
        eventName: LoungeResponseEventNames.authSuccess,
        listener: () => listener(),
      );

  IDisposable listenForAuthSuccessComplexResponse(Function() listener) {
    return listenEmptyEvent(
      eventName: LoungeResponseEventNames.authSuccess,
      listener: () => listener(),
    );
  }

  IDisposable listenForAuthFailed(Function() listener) => listenEmptyEvent(
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
