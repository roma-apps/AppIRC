import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class LoungeException implements Exception {}


class InvalidConnectionResponseException extends LoungeException {
  final LoungePreferences preferences;

  final bool authorizedReceived;
  final bool configReceived;
  final bool commandReceived;
  final bool chatInitReceived;

  InvalidConnectionResponseException(this.preferences, this.authorizedReceived,
      this.configReceived, this.commandReceived, this.chatInitReceived);
}

class NotImplementedYetException implements LoungeException {}

class JoinChannelInputLoungeRequestBody extends InputLoungeRequestBody {
  ChatNetworkChannelPreferences preferences;

  JoinChannelInputLoungeRequestBody(this.preferences, int target)
      : super(
            target: target,
            content: "/join ${preferences.name} ${preferences.password}");

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
