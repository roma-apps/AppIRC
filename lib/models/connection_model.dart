import 'package:flutter_appirc/models/thelounge_model.dart';

class ChannelsConnection {
  NetworkPreferences networkPreferences;
  UserPreferences userPreferences;

  ChannelsConnection({this.networkPreferences, this.userPreferences});

  TheLoungeRequest toLoungeRequest() => TheLoungeRequest(
      "network:new",
      NetworkNewTheLoungeRequestBody(
        username: userPreferences.nickname,
        join: userPreferences.channels,
        realname: userPreferences.realName,
        password: userPreferences.password,
        host: networkPreferences.serverHost,
        port: networkPreferences.serverPort,
        rejectUnauthorized: networkPreferences.useOnlyTrustedCertificates
            ? theLoungeOn
            : theLoungeOff,
        tls: networkPreferences.useTls ? theLoungeOn : theLoungeOff,
      ));
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
  static const String defaultChannels = "#thelounge-spam";

  String nickname;
  String password;
  String realName;
  String channels;

  UserPreferences({this.nickname, this.password, this.realName, this.channels});
}
