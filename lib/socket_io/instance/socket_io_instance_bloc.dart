import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc_impl.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/socket_io/socket_io_model.dart';
import 'package:flutter_appirc/socket_io/socket_io_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("socket_io_instance_bloc.dart");

const _defaultTimeoutDuration = Duration(seconds: 5);
const _defaultCheckResultIntervalDuration = Duration(milliseconds: 500);

class SocketIOInstanceBloc extends AsyncInitLoadingBloc {
  final SocketIOService socketIoService;
  final String uri;

  // ignore: close_sinks
  final BehaviorSubject<SocketIoConnectionState> connectionStateSubject =
      BehaviorSubject();

  Stream<SocketIoConnectionState> get connectionStateStream =>
      connectionStateSubject.stream;

  SocketIoConnectionState get connectionState => connectionStateSubject.value;

  Stream<SimpleSocketIoConnectionState> get simpleConnectionStateStream =>
      connectionStateStream.map(
        (connectionState) => connectionState?.toSimpleSocketIoConnectionState(),
      );

  SimpleSocketIoConnectionState get simpleConnectionState =>
      connectionState?.toSimpleSocketIoConnectionState();

  SocketIOInstanceBloc({
    @required this.socketIoService,
    @required this.uri,
  }) {
    addDisposable(subject: connectionStateSubject);
  }

  SocketIO socketIO;

  bool get isInitialized => socketIO != null;

  @override
  Future internalAsyncInit() async {
    var socketOptions = _createSocketOptions(uri);
    _logger.fine(() => "init socketOptions = $socketOptions");
    socketIO = await socketIoService.createInstance(socketOptions);

    connectionStateSubject.add(SocketIoConnectionState.initialized);
    _logger.fine(() => "init _socketIO = $socketIO");

    addDisposable(
      disposable: _listenConnectionState(
        (socketState, eventName, data) {
          _logger.fine(() => "onNewState => $socketState "
              "eventName = $eventName "
              "data = $data");
          connectionStateSubject.add(socketState);
        },
      ),
    );
  }

  Future<T> doSomethingAndWaitForResult<T>({
    @required IDisposable listenDisposable,
    @required Future Function() action,
    @required Future<T> Function() resultChecker,
    Duration timeoutDuration = _defaultTimeoutDuration,
    Duration checkResultIntervalDuration = _defaultCheckResultIntervalDuration,
  }) async {
    assert(isInitialized);

    DateTime startTime = DateTime.now();

    T result;
    try {
      await action();

      while (result == null) {
        result = await resultChecker();
        DateTime now = DateTime.now();

        var diff = now.difference(startTime).abs();

        if (diff > timeoutDuration) {
          throw TimeoutException("Socket IO timeout", timeoutDuration);
        }
        await Future.delayed(_defaultCheckResultIntervalDuration);
      }
    } finally {
      await listenDisposable?.dispose();
    }
    return result;
  }

  Future<SocketIoConnectionState> connectAndWaitForConnectionResult({
    Duration timeoutDuration = _defaultTimeoutDuration,
    Duration checkResultIntervalDuration = _defaultCheckResultIntervalDuration,
  }) async {
    assert(isInitialized);
    assert(connectionState == SocketIoConnectionState.initialized);

    try {
      return doSomethingAndWaitForResult(
        action: () => connect(),
        resultChecker: () async {
          _logger
              .finest(() => "resultChecker connectionState $connectionState");

          if (connectionState != null &&
              connectionState != SocketIoConnectionState.connecting &&
              connectionState != SocketIoConnectionState.initialized) {
            return connectionState;
          } else {
            return null;
          }
        },
        listenDisposable: null,
      );
    } on TimeoutException catch (e) {
      _logger.warning(() => "TimeoutException", e);
      connectionStateSubject.add(SocketIoConnectionState.connectTimeout);
      return connectionState;
    } catch (e, stackTrace) {
      _logger.shout(
          () => "connectAndWaitForConnectionResult error", e, stackTrace);
      connectionStateSubject.add(SocketIoConnectionState.connectError);
      return connectionState;
    }
  }

  void on(
    String eventName,
    SocketEventListener listener,
  ) {
    assert(isInitialized);
    return socketIO.on(
      eventName,
      listener,
    );
  }

  IDisposable listen(String eventName, SocketEventListener listener) {
    var internalListener = (data) {
      listener(data);
    };
    socketIO.on(eventName, internalListener);

    return CustomDisposable(() {
      socketIO.off(eventName, internalListener);
    });
  }

  IDisposable addConnectListener(SocketEventListener callback) {
    var listener = (data) {
      callback(data);
    };

    onConnect(listener);

    return CustomDisposable(() {
      offConnect(listener);
    });
  }

  IDisposable addDisconnectListener(SocketEventListener callback) {
    var listener = (data) {
      callback(data);
    };

    onDisconnect(listener);

    return CustomDisposable(() {
      offDisconnect(listener);
    });
  }

  IDisposable addConnectingListener(SocketEventListener callback) {
    var listener = (data) {
      callback(data);
    };

    onConnecting(listener);

    return CustomDisposable(() {
      offConnecting(listener);
    });
  }

  IDisposable addConnectErrorListener(SocketEventListener callback) {
    var listener = (data) {
      callback(data);
    };

    onConnectError(listener);

    return CustomDisposable(() {
      offConnectError(listener);
    });
  }

  IDisposable addConnectTimeoutListener(SocketEventListener callback) {
    var listener = (data) {
      callback(data);
    };

    onConnectTimeout(listener);

    return CustomDisposable(() {
      offConnectTimeout(listener);
    });
  }

  void onConnect(SocketEventListener listener) => socketIO.onConnect(listener);

  void onDisconnect(SocketEventListener listener) =>
      socketIO.onDisconnect(listener);

  void onConnecting(SocketEventListener listener) =>
      socketIO.onConnecting(listener);

  void onConnectError(SocketEventListener listener) =>
      socketIO.onConnectError(listener);

  void onConnectTimeout(SocketEventListener listener) =>
      socketIO.onConnectTimeout(listener);

  void onReconnect(SocketEventListener listener) =>
      socketIO.onReconnect(listener);

  void onReconnectError(SocketEventListener listener) =>
      socketIO.onReconnectError(listener);

  void onReconnectFailed(SocketEventListener listener) =>
      socketIO.onReconnectFailed(listener);

  void onReconnecting(SocketEventListener listener) =>
      socketIO.onReconnecting(listener);

  void onError(SocketEventListener listener) => socketIO.onError(listener);

  void onPing(SocketEventListener listener) => socketIO.onPing(listener);

  void onPong(SocketEventListener listener) => socketIO.onPong(listener);

  void offConnect(SocketEventListener listener) =>
      socketIO.off(SocketIO.CONNECT, listener);

  void offDisconnect(SocketEventListener listener) =>
      socketIO.off(SocketIO.DISCONNECT, listener);

  void offConnecting(SocketEventListener listener) =>
      socketIO.off(SocketIO.CONNECTING, listener);

  void offConnectError(SocketEventListener listener) =>
      socketIO.off(SocketIO.CONNECT_ERROR, listener);

  void offConnectTimeout(SocketEventListener listener) =>
      socketIO.off(SocketIO.CONNECT_TIMEOUT, listener);

  void offReconnect(SocketEventListener listener) =>
      socketIO.off(SocketIO.RECONNECT, listener);

  void offReconnectError(SocketEventListener listener) =>
      socketIO.off(SocketIO.RECONNECT_ERROR, listener);

  void offReconnectFailed(SocketEventListener listener) =>
      socketIO.off(SocketIO.RECONNECT_FAILED, listener);

  void offReconnecting(SocketEventListener listener) =>
      socketIO.off(SocketIO.RECONNECTING, listener);

  void offError(SocketEventListener listener) =>
      socketIO.off(SocketIO.ERROR, listener);

  void offPing(SocketEventListener listener) =>
      socketIO.off(SocketIO.PING, listener);

  void offPong(SocketEventListener listener) =>
      socketIO.off(SocketIO.PONG, listener);

  void off(String type, SocketEventListener listener) =>
      socketIO.off(type, listener);

  IDisposable _listenConnectionState(
      void Function(SocketIoConnectionState, String, String) listener) {
    SocketEventListener connectListener = (data) =>
        listener(SocketIoConnectionState.connected, "connected", data);
    SocketEventListener disconnectListener = (data) =>
        listener(SocketIoConnectionState.disconnected, "disconnected", data);
    SocketEventListener connectErrorListener = (data) =>
        listener(SocketIoConnectionState.connectError, "connectError", data);
    SocketEventListener connectTimeoutListener = (data) => listener(
        SocketIoConnectionState.connectTimeout, "connectTimeout", data);
    SocketEventListener connectingListener = (data) =>
        listener(SocketIoConnectionState.connecting, "connecting", data);
    SocketEventListener reconnectListener = (data) =>
        listener(SocketIoConnectionState.reconnected, "reconnect", data);
    SocketEventListener reconnectFailedListener = (data) => listener(
        SocketIoConnectionState.reconnectFailed, "reconnectFailed", data);
    SocketEventListener reconnectErrorListener = (data) => listener(
        SocketIoConnectionState.reconnectError, "reconnectError", data);
    SocketEventListener reconnectingListener = (data) =>
        listener(SocketIoConnectionState.reconnecting, "reconnecting", data);
    onConnect(connectListener);
    onDisconnect(disconnectListener);
    onConnectError(connectErrorListener);
    onConnectTimeout(connectTimeoutListener);
    onConnecting(connectingListener);
    onReconnect(reconnectListener);
    onReconnectFailed(reconnectFailedListener);
    onReconnectError(reconnectErrorListener);
    onReconnecting(reconnectingListener);

    return CustomDisposable(
      () {
        offConnect(connectListener);
        offDisconnect(disconnectListener);
        offConnectError(connectErrorListener);
        offConnectTimeout(connectTimeoutListener);
        offConnecting(connectingListener);
        offReconnect(reconnectListener);
        offReconnectFailed(reconnectFailedListener);
        offReconnectError(reconnectErrorListener);
        offReconnecting(reconnectingListener);
      },
    );
  }

  Future connect() {
    assert(isInitialized);
    assert(connectionState == SocketIoConnectionState.initialized);
    return socketIO.connect();
  }

  Future emit(SocketIOCommand command) {
    assert(isInitialized);
    return socketIO.emit(
      command.eventName,
      command.parameters,
    );
  }

  Future disconnect() {
    assert(isInitialized);
    return dispose();
  }

  @override
  Future dispose() async {
    await super.dispose();
    if (socketIO != null) {
      try {
        await socketIoService.clearInstance(socketIO);
      } catch (e, stackTrace) {
        _logger.warning(
          () => "error during disposing",
          e,
          stackTrace,
        );
      }
    }
  }

  SocketOptions _createSocketOptions(String host) => SocketOptions(
        //Socket IO server URI
        host, //Enable or disable platform channel logging
        enableLogging: !kReleaseMode && !kProfileMode,
        transports: [
          Transports.WEB_SOCKET,
          Transports.POLLING
        ], //Enable required transport
      );
}
