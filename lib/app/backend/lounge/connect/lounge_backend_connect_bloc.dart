import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/api/lounge_backend_socket_io_api_wrapper_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _logger = Logger("lounge_backend_connect_bloc.dart");

class LoungeBackendConnectBloc extends DisposableOwner {
  final LoungeBackendSocketIoApiWrapperBloc loungeBackendSocketIoApiWrapperBloc;

  final BehaviorSubject<LoungeConnectDetails> connectDetailsSubject =
      BehaviorSubject.seeded(null);

  final BehaviorSubject<Auth4xPerformComplexLoungeResponse>
      auth4xPerformComplexResponseSubject = BehaviorSubject.seeded(null);

  Stream<Auth4xPerformComplexLoungeResponse>
      get authPerformComplexResponseStream =>
          auth4xPerformComplexResponseSubject.stream;

  Auth4xPerformComplexLoungeResponse get authPerformComplexResponse =>
      auth4xPerformComplexResponseSubject.value;

  final BehaviorSubject<Auth3xComplexLoungeResponse>
      auth3xComplexLoungeResponseSubject = BehaviorSubject.seeded(null);

  Stream<Auth3xComplexLoungeResponse> get authComplexLoungeResponseStream =>
      auth3xComplexLoungeResponseSubject.stream;

  Auth3xComplexLoungeResponse get authComplexLoungeResponse =>
      auth3xComplexLoungeResponseSubject.value;

  final Channel Function() currentChannelExtractor;

  final Future<int> Function() lastMessageRemoteIdExtractor;

  Stream<LoungeConnectDetails> get connectDetailsStream =>
      connectDetailsSubject.stream;

  LoungeConnectDetails get connectDetails => connectDetailsSubject.value;

  LoungeVersion get loungeVersion => connectDetails?.loungeVersion;

  Stream<LoungeBackendConnectState> get connectStateStream =>
      loungeBackendSocketIoApiWrapperBloc
          .socketIOInstanceBloc.simpleConnectionStateStream
          .map(
        (simpleSocketConnectionState) =>
            simpleSocketConnectionState.toLoungeBackendConnectState(),
      );

  LoungeBackendConnectState get connectState =>
      loungeBackendSocketIoApiWrapperBloc
          .socketIOInstanceBloc.simpleConnectionState
          .toLoungeBackendConnectState();

  final LoungeAuthPreferences loungeAuthPreferences;

  LoungeBackendAuthState get authState => calculateAuthState(
        backendMode: backendMode,
        authPerformResponse: authPerformComplexResponse,
        connectState: connectState,
      );

  Stream<LoungeBackendAuthState> get authStateStream => Rx.combineLatest3(
        backendModeStream,
        connectStateStream,
        authPerformComplexResponseStream,
        (backendMode, authPerformResponse, connectState) => calculateAuthState(
          backendMode: backendMode,
          authPerformResponse: authPerformResponse,
          connectState: connectState,
        ),
      );

  LoungeBackendMode get backendMode => connectDetails?.backendMode;

  Stream<LoungeBackendMode> get backendModeStream =>
      connectDetailsStream.map((connectDetails) => connectDetails?.backendMode);

  ChatInitInformation get chatInit {
    InitLoungeResponseBody initLoungeResponseBody;
    switch (backendMode) {
      case LoungeBackendMode.private:
        switch (loungeVersion) {
          case LoungeVersion.version3_x:
            initLoungeResponseBody ??= authComplexLoungeResponse
                ?.authorized3xComplexLoungeResponse?.initLoungeResponseBody;
            break;
          case LoungeVersion.version4_x:
            initLoungeResponseBody = authPerformComplexResponse
                ?.auth4xSuccessComplexLoungeResponse?.initLoungeResponseBody;

            break;
        }

        break;
      case LoungeBackendMode.public:
        switch (loungeVersion) {
          case LoungeVersion.version3_x:
            initLoungeResponseBody ??= connectDetails?.publicPart
                ?.authorized3xComplexLoungeResponse?.initLoungeResponseBody;
            break;
          case LoungeVersion.version4_x:
            initLoungeResponseBody = connectDetails?.publicPart
                ?.auth4xSuccessComplexLoungeResponse?.initLoungeResponseBody;
            break;
        }

        break;
    }

    if (initLoungeResponseBody != null) {
      return toChatInitInformation(initLoungeResponseBody);
    } else {
      return null;
    }
  }

  ChatConfig get config => _calculateConfig(
        authPerformResponse: authPerformComplexResponse,
        authComplexLoungeResponse: authComplexLoungeResponse,
        connectDetails: connectDetails,
      );

  Stream<ChatConfig> get configStream => Rx.combineLatest3(
        connectDetailsStream,
        authPerformComplexResponseStream,
        authComplexLoungeResponseStream,
        (
          connectDetails,
          authPerformResponse,
          authComplexLoungeResponse,
        ) =>
            _calculateConfig(
          authPerformResponse: authPerformResponse,
          connectDetails: connectDetails,
          authComplexLoungeResponse: authComplexLoungeResponse,
        ),
      );

  ChatConfig _calculateConfig({
    @required Auth4xPerformComplexLoungeResponse authPerformResponse,
    @required LoungeConnectDetails connectDetails,
    @required Auth3xComplexLoungeResponse authComplexLoungeResponse,
  }) {
    ConfigurationLoungeResponseBody configLoungeResponseBody;
    CommandsLoungeResponseBody commandsLoungeResponseBody;
    switch (backendMode) {
      case LoungeBackendMode.private:
        switch (loungeVersion) {
          case LoungeVersion.version3_x:
            configLoungeResponseBody ??= authComplexLoungeResponse
                ?.authorized3xComplexLoungeResponse
                ?.configurationLoungeResponseBody;
            commandsLoungeResponseBody ??= authComplexLoungeResponse
                ?.authorized3xComplexLoungeResponse?.commandsLoungeResponseBody;
            break;
          case LoungeVersion.version4_x:
            configLoungeResponseBody = authPerformResponse
                ?.auth4xSuccessComplexLoungeResponse
                ?.configurationLoungeResponseBody;
            commandsLoungeResponseBody = authPerformResponse
                ?.auth4xSuccessComplexLoungeResponse
                ?.commandsLoungeResponseBody;
            break;
        }

        break;
      case LoungeBackendMode.public:
        switch (loungeVersion) {
          case LoungeVersion.version3_x:
            configLoungeResponseBody ??= connectDetails
                ?.publicPart
                ?.authorized3xComplexLoungeResponse
                ?.configurationLoungeResponseBody;
            commandsLoungeResponseBody ??= connectDetails?.publicPart
                ?.authorized3xComplexLoungeResponse?.commandsLoungeResponseBody;
            break;
          case LoungeVersion.version4_x:
            configLoungeResponseBody = connectDetails
                ?.publicPart
                ?.auth4xSuccessComplexLoungeResponse
                ?.configurationLoungeResponseBody;
            commandsLoungeResponseBody = connectDetails
                ?.publicPart
                ?.auth4xSuccessComplexLoungeResponse
                ?.commandsLoungeResponseBody;
            break;
        }

        break;
    }

    if (configLoungeResponseBody != null) {
      return toChatConfig(
        loungeConfig: configLoungeResponseBody,
        commands: commandsLoungeResponseBody?.commands,
      );
    } else {
      return null;
    }
  }

  Future<LoungeConnectDetails> connectAndWaitForResult() async {
    _logger.finest(() => "connectAndWaitForResult");
    var loungeConnectDetails =
        await loungeBackendSocketIoApiWrapperBloc.connectAndWaitForResponse();

    connectDetailsSubject.add(loungeConnectDetails);

    return loungeConnectDetails;
  }

  Future<LoungeConnectAndAuthDetails> connectAndLoginAndWaitForResult() async {
    _logger.finest(() => "connectAndLoginAndWaitForResult");
    var connectDetails =
        await loungeBackendSocketIoApiWrapperBloc.connectAndWaitForResponse();

    var loungeVersion = connectDetails?.loungeVersion;

    _logger.finest(() => "connectAndLoginAndWaitForResult loungeVersion $loungeVersion");

    switch (loungeVersion) {
      case LoungeVersion.version3_x:
        Auth3xComplexLoungeResponse auth3xComplexLoungeResponse;
        if (connectDetails.isPrivateMode) {
          if (loungeAuthPreferences != null) {
            auth3xComplexLoungeResponse = await login3x();
            auth3xComplexLoungeResponseSubject.add(auth3xComplexLoungeResponse);
          }
        }

        connectDetailsSubject.add(connectDetails);

        return LoungeConnectAndAuthDetails.version3x(
          connectDetails: connectDetails,
          auth3xComplexLoungeResponse: auth3xComplexLoungeResponse,
        );
        break;
      case LoungeVersion.version4_x:
        Auth4xPerformComplexLoungeResponse authPerformComplexLoungeResponse;
        if (connectDetails.isPrivateMode) {
          if (loungeAuthPreferences != null) {
            authPerformComplexLoungeResponse = await login4x();
            auth4xPerformComplexResponseSubject
                .add(authPerformComplexLoungeResponse);
          }
        }

        connectDetailsSubject.add(connectDetails);

        return LoungeConnectAndAuthDetails.version4x(
          connectDetails: connectDetails,
          auth4xPerformComplexLoungeResponse: authPerformComplexLoungeResponse,
        );
        break;
    }

    throw "Invalid loungeVersion $loungeVersion";
  }

  LoungeBackendConnectBloc({
    @required this.loungeBackendSocketIoApiWrapperBloc,
    @required this.loungeAuthPreferences,
    @required this.currentChannelExtractor,
    @required this.lastMessageRemoteIdExtractor,
  }) {
    addDisposable(subject: connectDetailsSubject);
    addDisposable(subject: auth4xPerformComplexResponseSubject);
    addDisposable(subject: auth3xComplexLoungeResponseSubject);

    // listenFor4xReconnect();
  }

  void listenFor4xReconnect() {
    addDisposable(
      disposable: loungeBackendSocketIoApiWrapperBloc.listenForAuth4xStart(
        (auth) {
          // reconnect in private mode
          // public mode don't support reconnect to the same socket
          if (authPerformComplexResponse != null) {
            login4x();
          }
        },
      ),
    );
  }

  Future<Auth4xPerformComplexLoungeResponse> login4x() async {
    _logger.finest(() => "login4x");
    var auth4xPerformComplexLoungeResponse =
        await loungeBackendSocketIoApiWrapperBloc
            .sendAuth4xPerformAndWaitForResult(
      user: loungeAuthPreferences.username,
      password: loungeAuthPreferences.password,
      token: chatInit?.authToken,
      openChannelRemoteId: currentChannelExtractor != null
          ? currentChannelExtractor()?.remoteId
          : null,
      lastMessageRemoteId: lastMessageRemoteIdExtractor != null
          ? await lastMessageRemoteIdExtractor()
          : null,
      hasConfig: config != null,
    );

    auth4xPerformComplexResponseSubject.add(auth4xPerformComplexLoungeResponse);

    return auth4xPerformComplexLoungeResponse;
  }

  Future<Auth3xComplexLoungeResponse> login3x() async {
    _logger.finest(() => "login3x");

    var auth3xComplexLoungeResponse =
        await loungeBackendSocketIoApiWrapperBloc.sendAuth3xAndWaitForResult(
      user: loungeAuthPreferences.username,
      password: loungeAuthPreferences.password,
      token: chatInit?.authToken,
      openChannelRemoteId: currentChannelExtractor != null
          ? currentChannelExtractor()?.remoteId
          : null,
      lastMessageRemoteId: lastMessageRemoteIdExtractor != null
          ? await lastMessageRemoteIdExtractor()
          : null,
    );

    auth3xComplexLoungeResponseSubject.add(auth3xComplexLoungeResponse);

    return auth3xComplexLoungeResponse;
  }

  static LoungeBackendAuthState calculateAuthState({
    @required LoungeBackendMode backendMode,
    @required Auth4xPerformComplexLoungeResponse authPerformResponse,
    @required LoungeBackendConnectState connectState,
  }) {
    switch (connectState) {
      case LoungeBackendConnectState.connected:
        switch (backendMode) {
          case LoungeBackendMode.private:
            if (authPerformResponse?.isSuccess == true) {
              return LoungeBackendAuthState.logged;
            } else if (authPerformResponse?.isFail == true) {
              return LoungeBackendAuthState.loginFailed;
            } else {
              return LoungeBackendAuthState.waitForAuth;
            }
            break;
          case LoungeBackendMode.public:
            return LoungeBackendAuthState.logged;
            break;
        }

        throw "Unsupported loungeBackendMode $backendMode";
        break;
      case LoungeBackendConnectState.connecting:
      case LoungeBackendConnectState.disconnected:
        return LoungeBackendAuthState.notLogged;
        break;
    }
    throw "Unsupported connectState $connectState";
  }
}
