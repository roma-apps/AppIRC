import 'package:flutter/foundation.dart';

 const _lobbyType = "lobby";
 const _specialType = "special";
 const _queryType = "query";
 const _channelType = "channel";

class IRCNetworkChannelStatistics {
  final IRCNetworkChannel channel;
  final int unreadCount;

  IRCNetworkChannelStatistics(this.channel, this.unreadCount);


}

class IRCNetworkChannel {
  final String name;
  final IRCNetworkChannelType type;

  final int remoteId;

  bool isEditTopicPossible;

  bool get isLobby  => type == IRCNetworkChannelType.LOBBY;


  @override
  String toString() {
    return 'IRCNetworkChannel{name: $name, type: $type, remoteId: $remoteId, isEditTopicPossible: $isEditTopicPossible}';
  }

  IRCNetworkChannel(
      {@required this.name, @required this.type, @required this.remoteId, @required this.isEditTopicPossible});

}

enum IRCNetworkChannelType {
  LOBBY, SPECIAL, QUERY, CHANNEL, UNKNOWN
}

IRCNetworkChannelType detectIRCNetworkChannelType(String typeString) {
  var type = IRCNetworkChannelType.UNKNOWN;
  switch(typeString) {
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