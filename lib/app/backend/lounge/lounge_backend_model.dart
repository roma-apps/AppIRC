import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/irc/irc_commands_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';

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

class NotImplementedYetLoungeException implements LoungeException {}

class ChatJoinChannelInputLoungeJsonRequest extends InputLoungeJsonRequest {
  ChatNetworkChannelPreferences preferences;

  ChatJoinChannelInputLoungeJsonRequest.name(this.preferences, int target)
      : super(
            target,
            JoinIRCCommand.name(
                    channelName: preferences.name,
                    password: preferences.password)
                .asRawString);

  @override
  String toString() {
    return 'ChatJoinChannelInputLoungeJsonRequest{preferences: $preferences}';
  }
}

class ChatNetworkNewLoungeJsonRequest extends NetworkNewLoungeJsonRequest {
  final ChatNetworkPreferences networkPreferences;

  ChatNetworkNewLoungeJsonRequest.name(
      {@required this.networkPreferences, @required String join})
      : super.name(
          username:
              networkPreferences.networkConnectionPreferences.userPreferences.username,
          nick:
              networkPreferences.networkConnectionPreferences.userPreferences.nickname,
          join: join,
          realname:
              networkPreferences.networkConnectionPreferences.userPreferences.realName,
          password:
              networkPreferences.networkConnectionPreferences.userPreferences.password,
          host: networkPreferences
              .networkConnectionPreferences.serverPreferences.serverHost,
          port: networkPreferences
              .networkConnectionPreferences.serverPreferences.serverPort,
          rejectUnauthorized: toLoungeBoolean(networkPreferences
              .networkConnectionPreferences
              .serverPreferences
              .useOnlyTrustedCertificates),
          tls: toLoungeBoolean(networkPreferences
              .networkConnectionPreferences.serverPreferences.useTls),
          name: networkPreferences.networkConnectionPreferences.serverPreferences.name,
          commands: null, // set command only via edit interface
        );
}
