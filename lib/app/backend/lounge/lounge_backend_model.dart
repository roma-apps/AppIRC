import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_model_adapter.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/irc/irc_commands_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_request_model.dart';

abstract class LoungeException implements Exception {}

class InvalidResponseException extends LoungeException {
  final LoungePreferences preferences;

  final bool authorizedReceived;
  final bool configReceived;
  final bool commandReceived;
  final bool chatInitReceived;

  InvalidResponseException(
    this.preferences,
    this.authorizedReceived,
    this.configReceived,
    this.commandReceived,
    this.chatInitReceived,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvalidResponseException &&
          runtimeType == other.runtimeType &&
          preferences == other.preferences &&
          authorizedReceived == other.authorizedReceived &&
          configReceived == other.configReceived &&
          commandReceived == other.commandReceived &&
          chatInitReceived == other.chatInitReceived;

  @override
  int get hashCode =>
      preferences.hashCode ^
      authorizedReceived.hashCode ^
      configReceived.hashCode ^
      commandReceived.hashCode ^
      chatInitReceived.hashCode;

  @override
  String toString() {
    return 'InvalidResponseException{'
        'preferences: $preferences, '
        'authorizedReceived: $authorizedReceived, '
        'configReceived: $configReceived, '
        'commandReceived: $commandReceived, '
        'chatInitReceived: $chatInitReceived'
        '}';
  }
}

class NotImplementedYetLoungeException implements LoungeException {
  const NotImplementedYetLoungeException();
}

class ChatJoinChannelInputLoungeJsonRequest extends InputLoungeJsonRequest {
  ChannelPreferences preferences;

  ChatJoinChannelInputLoungeJsonRequest({
    @required this.preferences,
    @required int target,
  }) : super(
          target: target,
          text: JoinIRCCommand(
            channelName: preferences.name,
            password: preferences.password,
          ).asRawString,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ChatJoinChannelInputLoungeJsonRequest &&
          runtimeType == other.runtimeType &&
          preferences == other.preferences;

  @override
  int get hashCode => super.hashCode ^ preferences.hashCode;

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
          rejectUnauthorized: toLoungeBoolean(
            networkPreferences.networkConnectionPreferences.serverPreferences
                .useOnlyTrustedCertificates,
          ),
          tls: toLoungeBoolean(
            networkPreferences
                .networkConnectionPreferences.serverPreferences.useTls,
          ),
          name: networkPreferences
              .networkConnectionPreferences.serverPreferences.name,
          commands: null, // set command only via edit interface
        );
}

class LoungeHostInformation {
  bool connected;

  bool authRequired;
  bool authResponse;

  // TODO: remove todo when will be in master branch
  // only available in custom the lounge version
  // https://github.com/xal/thelounge/tree/xal/sign_up
  bool registrationSupported;

  bool get isPublicMode => connected && !authRequired;

  bool get isPrivateMode => connected && authRequired;

  LoungeHostInformation._name(
      {@required this.connected,
      @required this.authRequired,
      @required this.registrationSupported,
      @required this.authResponse});

  LoungeHostInformation.notConnected()
      : this._name(
          connected: false,
          authRequired: null,
          registrationSupported: null,
          authResponse: null,
        );

  LoungeHostInformation.connectedToPublic()
      : this._name(
          connected: true,
          authRequired: false,
          registrationSupported: false,
          authResponse: true,
        );

  LoungeHostInformation.connectedToPrivate(
      {@required bool authResponse, @required bool registrationSupported})
      : this._name(
            connected: true,
            authRequired: true,
            registrationSupported: registrationSupported,
            authResponse: authResponse);

  @override
  String toString() {
    return 'LoungeHostInformation{'
        'connected: $connected, '
        'authRequired: $authRequired, '
        'registrationSupported: $registrationSupported'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoungeHostInformation &&
          runtimeType == other.runtimeType &&
          connected == other.connected &&
          authRequired == other.authRequired &&
          authResponse == other.authResponse &&
          registrationSupported == other.registrationSupported;

  @override
  int get hashCode =>
      connected.hashCode ^
      authRequired.hashCode ^
      authResponse.hashCode ^
      registrationSupported.hashCode;
}
