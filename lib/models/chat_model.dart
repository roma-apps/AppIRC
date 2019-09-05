import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';

class Channel {
  String name;

  final int remoteId;


  @override
  String toString() {
    return 'Channel{name: $name, remoteId: $remoteId}';
  }

  Channel({@required this.name, @required this.remoteId});
}


class Network {
  String name;
  final String remoteId;

  List<Channel> channels;

  Network(this.name, this.remoteId, this.channels);

  @override
  String toString() {
    return 'Network{name: $name, remoteId: $remoteId, channels: $channels}';
  }


}


class ChannelMessage {
  String type;
  String author;
  String realName;
  DateTime date;
  String text;


  ChannelMessage.name({this.type, this.author, this.realName, this.date,
      this.text});

  @override
  String toString() {
    return 'ChannelMessage{author: $author, text: $text}';
  }


}

class ChannelsConnectionInfo {
  NetworkPreferences networkPreferences;
  UserPreferences userPreferences;
  String channels;
  static const String defaultChannels = "#thelounge-spam";

  ChannelsConnectionInfo(
      {this.networkPreferences, this.userPreferences, this.channels});
}

class NetworkPreferences {
  static const bool defaultUseTls = true;
  static const bool defaultUseOnlyTrustedCertificates = true;
  static const String defaultName = "Freenode";
  static const String defaultHost = "chat.freenode.net";
  static const String defaultPort = "6697";

  String name;
  String serverHost;
  String serverPort;
  bool useTls;
  bool useOnlyTrustedCertificates;

  NetworkPreferences(
      {this.name,
      this.serverHost,
      this.serverPort,
      this.useTls = defaultUseTls,
      this.useOnlyTrustedCertificates = defaultUseOnlyTrustedCertificates});
}

class UserPreferences {
  static const String defaultNick = "AppIRC";
  static const String defaultRealName = "AppIRC";
  static const String defaultUserName = "AppIRC";

  String nickname;
  String username;
  String password;
  String realName;

  UserPreferences({this.nickname, this.password, this.realName, this.username});
}
