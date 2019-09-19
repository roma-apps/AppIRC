
abstract class LoungeException implements Exception {}
abstract class ConnectionLoungeException implements LoungeException {}

class ConnectionTimeoutLoungeException implements ConnectionLoungeException {}

class ConnectionErrorLoungeException implements ConnectionLoungeException {
  final dynamic data;

  ConnectionErrorLoungeException(this.data);
}
class NotImplementedYetException implements LoungeException {
}