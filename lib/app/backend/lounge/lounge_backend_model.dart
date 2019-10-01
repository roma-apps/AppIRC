import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';

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

class JoinChannelInputLoungeRequestBody extends InputLoungeRequestBody {
  ChatNetworkChannelPreferences preferences;

  JoinChannelInputLoungeRequestBody(
    this.preferences,
    int target
  ) : super(target: target, content: "/join ${preferences.name} ${preferences.password}");

  @override
  String toString() {
    return 'JoinChannelInputLoungeRequestBody{preferences: $preferences}';
  }


}

class JoinNetworkLoungeRequest
    extends LoungeJsonRequest<NetworkNewLoungeRequestBody> {
  final ChatNetworkPreferences networkPreferences;

  JoinNetworkLoungeRequest(
      this.networkPreferences, NetworkNewLoungeRequestBody body)
      : super(name: LoungeRequestEventNames.networkNew, body: body);
}
