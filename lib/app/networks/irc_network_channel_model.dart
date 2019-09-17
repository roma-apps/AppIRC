import 'package:flutter/cupertino.dart';

import 'irc_network_model.dart';

const _lobbyType = "lobby";
const _specialType = "special";
const _queryType = "query";
const _channelType = "channel";


enum IRCNetworkChannelState { CONNECTED, DISCONNECTED }

class IRCNetworkChannel {
  int get localId => channelPreferences?.localId;

  int get localNetworkId => networkPreferences?.localId;

  final IRCNetworkConnectionPreferences networkPreferences;
  final IRCNetworkChannelPreferences channelPreferences;

  String get name => channelPreferences.name;
  final IRCNetworkChannelType type;

  final int remoteId;

  bool isEditTopicPossible;

  bool get isLobby => type == IRCNetworkChannelType.LOBBY;

  IRCNetworkChannel(
      {@required this.networkPreferences,
      @required this.channelPreferences,
      @required this.type,
      @required this.remoteId,
      @required this.isEditTopicPossible});

  bool get isConnected => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is IRCNetworkChannel &&
              runtimeType == other.runtimeType &&
              remoteId == other.remoteId;

  @override
  int get hashCode => remoteId.hashCode;



}

enum IRCNetworkChannelType { LOBBY, SPECIAL, QUERY, CHANNEL, UNKNOWN }

IRCNetworkChannelType detectIRCNetworkChannelType(String typeString) {
  var type = IRCNetworkChannelType.UNKNOWN;
  switch (typeString) {
    case _lobbyType:
      type = IRCNetworkChannelType.LOBBY;
      break;
    case _specialType:
      type = IRCNetworkChannelType.SPECIAL;
      break;
    case _queryType:
      type = IRCNetworkChannelType.QUERY;
      break;
    case _channelType:
      type = IRCNetworkChannelType.CHANNEL;
      break;
  }
  return type;
}
