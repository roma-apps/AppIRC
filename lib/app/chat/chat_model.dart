import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';

class ChatConfig {
  final NetworkConnectionPreferences defaultNetwork;
  final String defaultChannels;

  final bool fileUpload;
  final bool ldapEnabled;
  final bool displayNetwork;
  final bool lockNetwork;

  final bool prefetch;
  final bool public;
  final bool useHexIp;
  final int fileUploadMaxSizeInBytes;
  final List<String> commands;

  @override
  String toString() {
    return 'ChatConfig{'
        'defaultNetwork: $defaultNetwork, '
        'defaultChannels: $defaultChannels, '
        'fileUpload: $fileUpload, '
        'ldapEnabled: $ldapEnabled, '
        'displayNetwork: $displayNetwork, '
        'lockNetwork: $lockNetwork, '
        'prefetch: $prefetch, '
        'public: $public, '
        'useHexIp: $useHexIp, '
        'fileUploadMaxSize: $fileUploadMaxSizeInBytes, '
        'commands: $commands'
        '}';
  }

  ChatConfig({
    @required this.defaultNetwork,
    @required this.defaultChannels,
    @required this.fileUpload,
    @required this.ldapEnabled,
    @required this.displayNetwork,
    @required this.lockNetwork,
    @required this.prefetch,
    @required this.public,
    @required this.useHexIp,
    @required this.fileUploadMaxSizeInBytes,
    @required this.commands,
  });

  NetworkPreferences createDefaultNetworkPreferences() => NetworkPreferences(
        defaultNetwork,
        [
          ChannelPreferences(name: defaultChannels, password: ""),
        ],
      );
}

class ServerNameNotUniqueException implements Exception {}

class ChannelUser {
  final String nick;
  final String hostMask;
  final String realName;
  final String channels;
  final bool secureConnection;
  final String connectedTo;
  final DateTime connectedAt;
  final DateTime idleSince;

  final String mode;

  ChannelUser({
    @required this.nick,
    @required this.hostMask,
    @required this.realName,
    @required this.channels,
    @required this.secureConnection,
    @required this.connectedTo,
    @required this.connectedAt,
    @required this.idleSince,
    @required this.mode,
  });

  @override
  String toString() {
    return 'ChannelUser{'
        'nick: $nick, '
        'hostMask: $hostMask, '
        'realName: $realName, '
        'channels: $channels, '
        'secureConnection: $secureConnection, '
        'connectedTo: $connectedTo, '
        'connectedAt: $connectedAt, '
        'idleSince: $idleSince, '
        'mode: $mode'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelUser &&
          runtimeType == other.runtimeType &&
          nick == other.nick &&
          hostMask == other.hostMask &&
          realName == other.realName &&
          channels == other.channels &&
          secureConnection == other.secureConnection &&
          connectedTo == other.connectedTo &&
          connectedAt == other.connectedAt &&
          idleSince == other.idleSince &&
          mode == other.mode;

  @override
  int get hashCode =>
      nick.hashCode ^
      hostMask.hashCode ^
      realName.hashCode ^
      channels.hashCode ^
      secureConnection.hashCode ^
      connectedTo.hashCode ^
      connectedAt.hashCode ^
      idleSince.hashCode ^
      mode.hashCode;
}
