import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';

class Channel {
  String name;
  bool isActive = false;

  final int remoteId;

  Channel({@required this.name, @required this.remoteId});
}

class ChatMessage {
  int channelId;
  MsgTheLoungeResponseBody msg;

  ChatMessage(this.channelId, this.msg);


}

class ChannelMessage {
  String author;
  String text;

  ChannelMessage.name({@required this.author, @required this.text});


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

  String nickname;
  String password;
  String realName;

  UserPreferences({this.nickname, this.password, this.realName});
}
