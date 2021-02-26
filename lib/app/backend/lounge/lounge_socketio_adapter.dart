import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/socket_io/socket_io_model.dart';



ChatConnectionState mapConnectionState(SimpleSocketIoConnectionState socketState) {
  switch (socketState) {
    case SimpleSocketIoConnectionState.connected:
      return ChatConnectionState.connected;
      break;
    case SimpleSocketIoConnectionState.disconnected:
    case SimpleSocketIoConnectionState.initialized:
      return ChatConnectionState.disconnected;
      break;
    case SimpleSocketIoConnectionState.connecting:
      return ChatConnectionState.connecting;
      break;
  }
  throw Exception("invalid state $socketState");
}
