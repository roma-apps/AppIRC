import 'package:flutter_appirc/app/network/network_model.dart';

enum IRCNetworkChannelState { CONNECTED, DISCONNECTED }

class NetworkChannel {
  int get localId => channelPreferences?.localId;
  set localId(int newId) => channelPreferences.localId = newId;

  final IRCNetworkChannelPreferences channelPreferences;

  String get name => channelPreferences.name;
  final IRCNetworkChannelType type;

  final int remoteId;

  bool get isLobby => type == IRCNetworkChannelType.LOBBY;

  NetworkChannel(this.channelPreferences, this.type, this.remoteId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkChannel &&
          runtimeType == other.runtimeType &&
          remoteId == other.remoteId;

  @override
  int get hashCode => remoteId.hashCode;
}

enum IRCNetworkChannelType { LOBBY, SPECIAL, QUERY, CHANNEL, UNKNOWN }
