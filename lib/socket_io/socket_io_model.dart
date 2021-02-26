import 'package:flutter/widgets.dart';

class SocketIOCommand {
  final String eventName;
  final List<dynamic> parameters;

  SocketIOCommand({
    @required this.eventName,
    @required this.parameters,
  });

  @override
  String toString() => 'SocketIOCommand{'
      'eventName: $eventName, '
      'parameters: $parameters'
      '}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocketIOCommand &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          parameters == other.parameters;

  @override
  int get hashCode => eventName.hashCode ^ parameters.hashCode;
}

enum SocketIoConnectionState {
  initialized,
  connecting,
  reconnected,
  reconnecting,
  reconnectError,
  reconnectFailed,
  connected,
  connectError,
  connectTimeout,
  disconnected,
}

enum SimpleSocketIoConnectionState {
  initialized,
  connected,
  connecting,
  disconnected,
}

extension SocketIoConnectionStateExtension on SocketIoConnectionState {
  bool get isError =>
      this == SocketIoConnectionState.reconnectError ||
      this == SocketIoConnectionState.connectError;

  bool get isTimeout =>
      this == SocketIoConnectionState.connectTimeout;

  SimpleSocketIoConnectionState toSimpleSocketIoConnectionState() {
    switch (this) {
      case SocketIoConnectionState.initialized:
        return SimpleSocketIoConnectionState.initialized;
        break;
      case SocketIoConnectionState.reconnectError:
      case SocketIoConnectionState.reconnectFailed:
      case SocketIoConnectionState.connectError:
      case SocketIoConnectionState.connectTimeout:
      case SocketIoConnectionState.disconnected:
        return SimpleSocketIoConnectionState.disconnected;
        break;
      case SocketIoConnectionState.connecting:
      case SocketIoConnectionState.reconnecting:
        return SimpleSocketIoConnectionState.connecting;
        break;
      case SocketIoConnectionState.reconnected:
      case SocketIoConnectionState.connected:
        return SimpleSocketIoConnectionState.connected;
        break;
    }

    throw "Invalid $this";
  }
}
