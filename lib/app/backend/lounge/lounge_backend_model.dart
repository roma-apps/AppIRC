import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/irc/irc_commands_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';

abstract class LoungeComplexResponse {
  DateTime allRequiredDataReceivedTime;

  List<dynamic> get optionalFields;

  List<dynamic> get requiredFields;

  bool get isAllFieldsExist => isRequiredFieldsExist && isOptionalFieldsExist;

  bool get isOptionalFieldsExist => !optionalFields.contains(null);

  bool get isRequiredFieldsExist => !requiredFields.contains(null);

  LoungeComplexResponse();
}

abstract class LoungeException implements Exception {
  const LoungeException();
}

class NotImplementedYetLoungeException implements LoungeException {
  const NotImplementedYetLoungeException();
}

class ChatJoinChannelInputLoungeJsonRequest extends InputLoungeJsonRequest {
  final ChannelPreferences preferences;

  ChatJoinChannelInputLoungeJsonRequest({
    @required this.preferences,
    @required int targetChannelRemoteId,
  }) : super(
            targetChannelRemoteId: targetChannelRemoteId,
            text: JoinIRCCommand(
              channelName: preferences.name,
              password: preferences.password,
            ).asRawString);

  @override
  String toString() {
    return 'ChatJoinChannelInputLoungeJsonRequest{preferences: $preferences}';
  }
}

class ChatNetworkNewLoungeJsonRequest extends NetworkNewLoungeJsonRequest {
  final NetworkPreferences networkPreferences;

  ChatNetworkNewLoungeJsonRequest({
    @required this.networkPreferences,
    @required String join,
  }) : super(
          username: networkPreferences
              .networkConnectionPreferences.userPreferences.username,
          nick: networkPreferences
              .networkConnectionPreferences.userPreferences.nickname,
          join: join,
          realname: networkPreferences
              .networkConnectionPreferences.userPreferences.realName,
          password: networkPreferences
              .networkConnectionPreferences.userPreferences.password,
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
          name: networkPreferences
              .networkConnectionPreferences.serverPreferences.name,
          commands: null, // set command only via edit interface
        );
}
