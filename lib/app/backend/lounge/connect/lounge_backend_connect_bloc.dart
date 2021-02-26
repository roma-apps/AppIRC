import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/api/lounge_backend_socket_io_api_wrapper_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_response_model.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

final _logger = Logger("lounge_backend_connection_bloc.dart");

class LoungeBackendConnectBloc extends DisposableOwner {
  final LoungeBackendSocketIoApiWrapperBloc loungeBackendSocketIoApiWrapperBloc;

  final BehaviorSubject<LoungeConnectDetails> connectDetailsSubject =
      BehaviorSubject.seeded(null);

  final BehaviorSubject<AuthPerformComplexLoungeResponse>
      authPerformResponseSubject = BehaviorSubject.seeded(null);

  Stream<LoungeConnectDetails> get connectDetailsStream =>
      connectDetailsSubject.stream;

  LoungeConnectDetails get connectDetails => connectDetailsSubject.value;

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

  Stream<AuthPerformComplexLoungeResponse> get authPerformResponseStream =>
      authPerformResponseSubject.stream;

  AuthPerformComplexLoungeResponse get authPerformResponse =>
      authPerformResponseSubject.value;

  LoungeBackendAuthState get authState => calculateAuthState(
        backendMode: backendMode,
        authPerformResponse: authPerformResponse,
        connectState: connectState,
      );

  Stream<LoungeBackendAuthState> get authStateStream => Rx.combineLatest3(
        backendModeStream,
        connectStateStream,
        authPerformResponseStream,
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
        initLoungeResponseBody = authPerformResponse
            ?.authSuccessComplexLoungeResponse?.initLoungeResponseBody;
        break;
      case LoungeBackendMode.public:
        initLoungeResponseBody = connectDetails?.publicPart
            ?.authSuccessComplexLoungeResponse?.initLoungeResponseBody;
        break;
    }

    if (initLoungeResponseBody != null) {
      return toChatInitInformation(initLoungeResponseBody);
    } else {
      return null;
    }
  }

  ChatConfig get config {
    ConfigurationLoungeResponseBody configLoungeResponseBody;
    CommandsLoungeResponseBody commandsLoungeResponseBody;
    switch (backendMode) {
      case LoungeBackendMode.private:
        configLoungeResponseBody = authPerformResponse
            ?.authSuccessComplexLoungeResponse?.configurationLoungeResponseBody;
        commandsLoungeResponseBody = authPerformResponse
            ?.authSuccessComplexLoungeResponse?.commandsLoungeResponseBody;
        break;
      case LoungeBackendMode.public:
        configLoungeResponseBody = connectDetails?.publicPart
            ?.authSuccessComplexLoungeResponse?.configurationLoungeResponseBody;
        commandsLoungeResponseBody = connectDetails?.publicPart
            ?.authSuccessComplexLoungeResponse?.commandsLoungeResponseBody;
        break;
    }

    if (configLoungeResponseBody != null) {
      return toChatConfig(
          loungeConfig: configLoungeResponseBody,
          commands: commandsLoungeResponseBody?.commands);
    } else {
      return null;
    }
  }

  Stream<ChatConfig> get configStream => Rx.combineLatest2(
        connectDetailsStream,
        authPerformResponseStream,
        (connectDetails, authPerformResponse) {
          ConfigurationLoungeResponseBody configLoungeResponseBody;
          CommandsLoungeResponseBody commandsLoungeResponseBody;
          switch (backendMode) {
            case LoungeBackendMode.private:
              configLoungeResponseBody = authPerformResponse
                  ?.authSuccessComplexLoungeResponse
                  ?.configurationLoungeResponseBody;
              commandsLoungeResponseBody = authPerformResponse
                  ?.authSuccessComplexLoungeResponse
                  ?.commandsLoungeResponseBody;
              break;
            case LoungeBackendMode.public:
              configLoungeResponseBody = connectDetails
                  ?.publicPart
                  ?.authSuccessComplexLoungeResponse
                  ?.configurationLoungeResponseBody;
              commandsLoungeResponseBody = connectDetails
                  ?.publicPart
                  ?.authSuccessComplexLoungeResponse
                  ?.commandsLoungeResponseBody;
              break;
          }

          if (configLoungeResponseBody != null) {
            return toChatConfig(
                loungeConfig: configLoungeResponseBody,
                commands: commandsLoungeResponseBody?.commands);
          } else {
            return null;
          }
        },
      );

  Future<LoungeConnectDetails> connectAndWaitForResult() async {
    _logger.finest(() => "connectAndWaitForResult");
    var loungeConnectDetails =
        await loungeBackendSocketIoApiWrapperBloc.connectAndWaitForResponse();

    connectDetailsSubject.add(loungeConnectDetails);

    return loungeConnectDetails;
  }

  Future<LoungeConnectAndAuthDetails> connectAndLoginAndWaitForResult() async {
    _logger.finest(() => "connectAndLoginAndWaitForResult");
    var loungeConnectDetails =
        await loungeBackendSocketIoApiWrapperBloc.connectAndWaitForResponse();

    AuthPerformComplexLoungeResponse authPerformComplexLoungeResponse;
    if (loungeConnectDetails.isPrivateMode) {
      if (loungeAuthPreferences != null) {
        authPerformComplexLoungeResponse = await login();
        authPerformResponseSubject.add(authPerformComplexLoungeResponse);
      }
    }

    connectDetailsSubject.add(loungeConnectDetails);

    return LoungeConnectAndAuthDetails(
      connectDetails: connectDetails,
      authPerformComplexLoungeResponse: authPerformComplexLoungeResponse,
    );
  }

  LoungeBackendConnectBloc({
    @required this.loungeBackendSocketIoApiWrapperBloc,
    @required this.loungeAuthPreferences,
  }) {
    addDisposable(subject: connectDetailsSubject);
    addDisposable(subject: authPerformResponseSubject);

    addDisposable(
      disposable: loungeBackendSocketIoApiWrapperBloc.listenForAuthStart(
        (auth) {
          if (chatInit != null) {
            //   // reconnect
            //   var authToken = chatInit.authToken;
            //
            //   _logger.fine(() => "auth after reconnecting"
            //       " authToken $authToken"
            //       " auth $auth");
            //
            //   var result = await authAfterReconnect(
            //       token: authToken,
            //       activeChannelId: currentChannelExtractor()?.remoteId,
            //       lastMessageId: await lastMessageRemoteIdExtractor(),
            // user: loungePreferences?.authPreferences?.username,
            // waitForResult: true,
            // );
            //
            // _logger.fine(() => "auth after reconnecting result $result");
          }
        },
      ),
    );
  }

  Future<AuthPerformComplexLoungeResponse> login() async {
    _logger.finest(() => "login");
    var authPerformComplexLoungeResponse =
        await loungeBackendSocketIoApiWrapperBloc
            .sendAuthPerformAndWaitForResult(
      user: loungeAuthPreferences.username,
      password: loungeAuthPreferences.password,
      token: null,
      lastMessageRemoteId: null,
      openChannelRemoteId: null,
      hasConfig: null,
    );

    authPerformResponseSubject.add(authPerformComplexLoungeResponse);

    return authPerformComplexLoungeResponse;
  }

  static LoungeBackendAuthState calculateAuthState({
    @required LoungeBackendMode backendMode,
    @required AuthPerformComplexLoungeResponse authPerformResponse,
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

  Future authAfterReconnect({
    @required String token,
    @required int activeChannelId,
    @required int lastMessageId,
    @required String user,
    bool waitForResult = false,
  }) async {
    // _logger.fine(() => "authAfterReconnect "
    //     "token = $token "
    //     "activeChannelId = $activeChannelId "
    //     "lastMessageId = $lastMessageId "
    //     "waitForResult $waitForResult");
    //
    // var request = AuthReconnectLoungeJsonRequestBody(
    //   lastMessageId: lastMessageId,
    //   openChannelId: activeChannelId,
    //   user: user,
    //   token: token,
    // );
    // IDisposable disposable;
    // var result;
    // disposable = _listenForInit(
    //   socketIOInstanceBloc: socketIOInstanceBloc,
    //   listener: (chatInit) async {
    //     _logger.fine(() => "_listenForInit");
    //     result = chatInit;
    //   },
    // );
    // disposable = _listenForAuthorized(
    //   socketIOInstanceBloc: socketIOInstanceBloc,
    //   listener: () async {
    //     _logger.fine(() => "_listenForAuthorized");
    //   },
    // );
    // disposable = _listenForCommands(
    //   socketIOInstanceBloc: socketIOInstanceBloc,
    //   listener: (commands) async {
    //     _logger.fine(() => "_listenForAuthorized");
    //   },
    // );
    // await _sendRequest(
    //   request: request,
    //   isNeedAddRequestToPending: false,
    // );
    //
    // RequestResult<ChatInitInformation> requestResult;
    // if (waitForResult) {
    //   requestResult = await _doWaitForResult<ChatInitInformation>(() => result);
    // } else {
    //   requestResult = RequestResult.notWaitForResponse();
    // }
    // await disposable.dispose();
    // return requestResult;
  }
}
