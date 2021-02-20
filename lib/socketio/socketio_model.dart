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

enum SocketConnectionState { connected, disconnected, connecting }
