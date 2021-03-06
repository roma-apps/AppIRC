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
      auth4xPerformComplexLoungeResponseSubject = BehaviorSubject.seeded(null);

  Stream<Auth4xPerformComplexLoungeResponse>
      get auth4xPerformComplexLoungeResponseStream =>
          auth4xPerformComplexLoungeResponseSubject.stream;

  Auth4xPerformComplexLoungeResponse get auth4xPerformComplexLoungeResponse =>
      auth4xPerformComplexLoungeResponseSubject.value;

  final BehaviorSubject<Auth3xComplexLoungeResponse>
      auth3xComplexLoungeResponseSubject = BehaviorSubject.seeded(null);

  Stream<Auth3xComplexLoungeResponse> get auth3xComplexLoungeResponseStream =>
      auth3xComplexLoungeResponseSubject.stream;

  Auth3xComplexLoungeResponse get auth3xComplexLoungeResponse =>
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
        auth4xPerformLoungeResponse: auth4xPerformComplexLoungeResponse,
        auth3xComplexLoungeResponse: auth3xComplexLoungeResponse,
        connectState: connectState,
      );

  Stream<LoungeBackendAuthState> get authStateStream => Rx.combineLatest4(
        backendModeStream,
        connectStateStream,
        auth4xPerformComplexLoungeResponseStream,
        auth3xComplexLoungeResponseStream,
        (
          backendMode,
          connectState,
          auth4xPerformLoungeResponse,
          auth3xComplexLoungeResponse,
        ) =>
            calculateAuthState(
          backendMode: backendMode,
          auth4xPerformLoungeResponse: auth4xPerformLoungeResponse,
          auth3xComplexLoungeResponse: auth3xComplexLoungeResponse,
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
            initLoungeResponseBody ??= auth3xComplexLoungeResponse
                ?.authorized3xComplexLoungeResponse?.initLoungeResponseBody;
            break;
          case LoungeVersion.version4_x:
            initLoungeResponseBody = auth4xPerformComplexLoungeResponse
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
        auth4xPerformResponse: auth4xPerformComplexLoungeResponse,
        authComplexLoungeResponse: auth3xComplexLoungeResponse,
        connectDetails: connectDetails,
      );

  Stream<ChatConfig> get configStream => Rx.combineLatest3(
        connectDetailsStream,
        auth4xPerformComplexLoungeResponseStream,
        auth3xComplexLoungeResponseStream,
        (
          connectDetails,
          auth4xPerformResponse,
          authComplexLoungeResponse,
        ) =>
            _calculateConfig(
          auth4xPerformResponse: auth4xPerformResponse,
          connectDetails: connectDetails,
          authComplexLoungeResponse: authComplexLoungeResponse,
        ),
      );

  ChatConfig _calculateConfig({
    @required Auth4xPerformComplexLoungeResponse auth4xPerformResponse,
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
            configLoungeResponseBody = auth4xPerformResponse
                ?.auth4xSuccessComplexLoungeResponse
                ?.configurationLoungeResponseBody;
            commandsLoungeResponseBody = auth4xPerformResponse
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

    _logger.finest(
        () => "connectAndLoginAndWaitForResult loungeVersion $loungeVersion");

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
            auth4xPerformComplexLoungeResponseSubject
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
    addDisposable(subject: auth4xPerformComplexLoungeResponseSubject);
    addDisposable(subject: auth3xComplexLoungeResponseSubject);

    listenFor3xPrivateReconnect();
    listenFor4xPrivateReconnect();
  }

  void listenForPublicReconnect() {
    addDisposable(
      disposable: loungeBackendSocketIoApiWrapperBloc.listenForInit(
        (init) {
          // reconnect public
          if(backendMode == LoungeBackendMode.public) {

          }
        },
      ),
    );
  }

  void listenFor4xPrivateReconnect() {
    addDisposable(
      disposable: loungeBackendSocketIoApiWrapperBloc.listenForAuth4xStart(
        (auth) {
          if (auth4xPerformComplexLoungeResponse != null) {
            login4x();
          }
        },
      ),
    );
  }

  void listenFor3xPrivateReconnect() {
    addDisposable(
      disposable: loungeBackendSocketIoApiWrapperBloc.listenForAuth3x(
        (auth) {
          if (auth3xComplexLoungeResponse != null) {
            login3x();
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

    auth4xPerformComplexLoungeResponseSubject
        .add(auth4xPerformComplexLoungeResponse);

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
    @required Auth4xPerformComplexLoungeResponse auth4xPerformLoungeResponse,
    @required Auth3xComplexLoungeResponse auth3xComplexLoungeResponse,
    @required LoungeBackendConnectState connectState,
  }) {
    switch (connectState) {
      case LoungeBackendConnectState.connected:
        switch (backendMode) {
          case LoungeBackendMode.private:
            if (auth4xPerformLoungeResponse != null) {
              if (auth4xPerformLoungeResponse?.isSuccess == true) {
                return LoungeBackendAuthState.logged;
              } else if (auth4xPerformLoungeResponse?.isFail == true) {
                return LoungeBackendAuthState.loginFailed;
              } else {
                return LoungeBackendAuthState.waitForAuth;
              }
            } else if (auth3xComplexLoungeResponse != null) {
              if (auth3xComplexLoungeResponse?.isSuccess == true) {
                return LoungeBackendAuthState.logged;
              } else if (auth3xComplexLoungeResponse?.isFail == true) {
                return LoungeBackendAuthState.loginFailed;
              } else {
                return LoungeBackendAuthState.waitForAuth;
              }
            } else {
              throw "Invalid state";
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
