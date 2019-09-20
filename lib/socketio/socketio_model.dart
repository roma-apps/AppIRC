abstract class SocketIOCommand {
  String getName();

  List<dynamic> getBody();
}


enum SocketConnectionState {
  CONNECTED, DISCONNECTED, CONNECTING
}