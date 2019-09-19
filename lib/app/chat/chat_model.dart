

class ServerNameNotUniqueException implements Exception {}

class NetworkState {
  static final NetworkState empty = NetworkState();

  bool connected;

}
class NetworkChannelState {

  String topic;

  static final  NetworkChannelState empty = NetworkChannelState();

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

  ChannelUserInfo.name({this.nick, this.hostMask, this.realName, this.channels,
      this.secureConnection, this.connectedTo, this.connectedAt, this.idleSince,
      this.mode});


}