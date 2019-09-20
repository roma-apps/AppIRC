import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

class ChatConfig {
  final IRCNetworkConnectionPreferences defaultNetwork;
  final String defaultChannels;
  final String defaultPassword;
  final bool displayNetwork;
  final bool fileUpload;
  final bool ldapEnabled;
  final bool lockNetwork;
  final bool prefetch;
  final bool public;
  final bool useHexIp;
  final int fileUploadMaxSize;
  final List<String> commands;


  ChatConfig(this.defaultNetwork, this.defaultChannels, this.defaultPassword,
      this.displayNetwork, this.fileUpload, this.ldapEnabled, this.lockNetwork,
      this.prefetch, this.public, this.useHexIp, this.fileUploadMaxSize,
      this.commands);

  @override
  String toString() {
    return 'ChatConfig{defaultNetwork: $defaultNetwork,'
        ' defaultChannels: $defaultChannels,'
        ' displayNetwork: $displayNetwork, fileUpload: $fileUpload, '
        'ldapEnabled: $ldapEnabled, lockNetwork: $lockNetwork,'
        ' prefetch: $prefetch, public: $public, '
        'useHexIp: $useHexIp, fileUploadMaxSize: $fileUploadMaxSize,'
        ' commands: $commands}';
  }

  ChatConfig.name(
      {@required this.defaultNetwork,
      @required this.defaultChannels,
      @required this.defaultPassword,
      @required this.displayNetwork,
      @required this.fileUpload,
      @required this.ldapEnabled,
      @required this.lockNetwork,
      @required this.prefetch,
      @required this.public,
      @required this.useHexIp,
      @required this.fileUploadMaxSize,
      @required this.commands});
}

class ServerNameNotUniqueException implements Exception {}

class NetworkState {
  static final NetworkState empty = NetworkState();

  bool connected;
}

class NetworkChannelState {
  String topic;

  static final NetworkChannelState empty = NetworkChannelState();

  var unreadCount;
}

class NetworkChannelInfo {
  final String name;
  final String topic;
  final int usersCount;

  NetworkChannelInfo(this.name, this.topic, this.usersCount);
}

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
