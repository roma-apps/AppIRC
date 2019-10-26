import 'package:flutter/widgets.dart';

class SocketIOCommand {
  final String eventName;
  final List<dynamic> parameters;
  SocketIOCommand(this.eventName, this.parameters);

  SocketIOCommand.name({@required this.eventName, @required this.parameters});
}

enum SocketConnectionState { CONNECTED, DISCONNECTED, CONNECTING }
