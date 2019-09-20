import 'package:flutter_appirc/lounge/lounge_model.dart';

abstract class LoungeException implements Exception {}

class PrivateLoungeNotSupportedException extends LoungeException {
  final LoungeConnectionPreferences preferences;

  PrivateLoungeNotSupportedException(this.preferences);
}

class InvalidConnectionResponseException extends LoungeException {
  final LoungeConnectionPreferences preferences;

  final bool authReceived;
  final bool configReceived;
  final bool commandReceived;

  InvalidConnectionResponseException(this.preferences, this.authReceived,
      this.configReceived, this.commandReceived);


}

class NotImplementedYetException implements LoungeException {}
