import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class ChatConfig {

  final ChatNetworkConnectionPreferences defaultNetwork;
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


  ChatConfig(this.defaultNetwork, this.defaultChannels, this.fileUpload,
      this.ldapEnabled, this.displayNetwork, this.lockNetwork, this.prefetch,
      this.public, this.useHexIp, this.fileUploadMaxSizeInBytes, this.commands);


  @override
  String toString() {
    return 'ChatConfig{defaultNetwork: $defaultNetwork, defaultChannels: '
        '$defaultChannels, fileUpload: $fileUpload, '
        'ldapEnabled: $ldapEnabled, displayNetwork: $displayNetwork, '
        'lockNetwork: $lockNetwork, prefetch: $prefetch, public: $public, '
        'useHexIp: $useHexIp, fileUploadMaxSize: $fileUploadMaxSizeInBytes, '
        'commands: $commands}';
  }

  ChatConfig.name(
      {@required this.defaultNetwork,
      @required this.defaultChannels,
      @required this.fileUpload,
      @required this.ldapEnabled,
      @required this.displayNetwork,
      @required this.lockNetwork,
      @required this.prefetch,
      @required this.public,
      @required this.useHexIp,
      @required this.fileUploadMaxSizeInBytes,
      @required this.commands});




}

class ServerNameNotUniqueException implements Exception {}

class NetworkChannelUser {
  final String nick;
  final String hostMask;
  final String realName;
  final String channels;
  final bool secureConnection;
  final String connectedTo;
  final DateTime connectedAt;
  final DateTime idleSince;

  String mode;

  NetworkChannelUser(
      this.nick,
      this.hostMask,
      this.realName,
      this.channels,
      this.secureConnection,
      this.connectedTo,
      this.connectedAt,
      this.idleSince);

  NetworkChannelUser.name(
      {this.nick,
      this.hostMask,
      this.realName,
      this.channels,
      this.secureConnection,
      this.connectedTo,
      this.connectedAt,
      this.idleSince,
      this.mode});
}
