import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class ChatConfig {
  final ChatNetworkConnectionPreferences defaultNetwork;
  final String defaultChannels;
  final String defaultPassword;

  final bool fileUpload;
  final bool ldapEnabled;

  final bool prefetch;
  final bool public;
  final bool useHexIp;
  final int fileUploadMaxSize;
  final List<String> commands;


  ChatConfig(this.defaultNetwork, this.defaultChannels, this.defaultPassword,
      this.fileUpload, this.ldapEnabled,
      this.prefetch, this.public, this.useHexIp, this.fileUploadMaxSize,
      this.commands);


  @override
  String toString() {
    return 'ChatConfig{defaultNetwork: $defaultNetwork,'
        ' defaultChannels: $defaultChannels, '
        'defaultPassword: $defaultPassword, fileUpload: $fileUpload, '
        'ldapEnabled: $ldapEnabled, prefetch: $prefetch, '
        'public: $public, useHexIp: $useHexIp, '
        'fileUploadMaxSize: $fileUploadMaxSize, commands: $commands}';
  }

  ChatConfig.name(
      {@required this.defaultNetwork,
      @required this.defaultChannels,
      @required this.defaultPassword,
      @required this.fileUpload,
      @required this.ldapEnabled,
      @required this.prefetch,
      @required this.public,
      @required this.useHexIp,
      @required this.fileUploadMaxSize,
      @required this.commands});
}

class ServerNameNotUniqueException implements Exception {}


class ChannelUserInfo {
  final String nick;
  final String hostMask;
  final String realName;
  final String channels;
  final bool secureConnection;
  final String connectedTo;
  final DateTime connectedAt;
  final DateTime idleSince;

  String mode;

  ChannelUserInfo(
      this.nick,
      this.hostMask,
      this.realName,
      this.channels,
      this.secureConnection,
      this.connectedTo,
      this.connectedAt,
      this.idleSince);

  ChannelUserInfo.name(
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
