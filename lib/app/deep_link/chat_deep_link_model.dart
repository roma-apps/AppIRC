class ChatDeepLink {
  final String host;
  final int port;
  final String channel;

  ChatDeepLink(this.host, this.port, this.channel);

  @override
  String toString() {
    return 'ChatDeepLink{host: $host, port: $port, channel: $channel}';
  }
}
