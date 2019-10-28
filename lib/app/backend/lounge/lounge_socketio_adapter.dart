import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:flutter_appirc/socketio/socketio_model.dart';

SocketIOCommand toSocketIOCommand(LoungeRequest request) {
  if (request is LoungeJsonRequest) {
    return SocketIOCommand.name(
        eventName: request.eventName, parameters: [request.toJson()]);
  } else if (request is LoungeRawRequest) {
    return SocketIOCommand.name(
        eventName: request.eventName, parameters: [request.bodyAsString]);
  } else {
    throw "Unsupported type $request";
  }
}

ChatConnectionState mapConnectionState(SocketConnectionState socketState) {
  switch (socketState) {
    case SocketConnectionState.connected:
      return ChatConnectionState.connected;
      break;
    case SocketConnectionState.disconnected:
      return ChatConnectionState.disconnected;
      break;
    case SocketConnectionState.connecting:
      return ChatConnectionState.connecting;
      break;
  }
  throw Exception("invalid state $socketState");
}
