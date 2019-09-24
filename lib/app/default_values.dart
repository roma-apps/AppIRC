import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

LoungeConnectionPreferences createDefaultLoungePreferences(
        BuildContext context) =>
    LoungeConnectionPreferences(host: "https://demo.thelounge.chat/");
//LoungePreferences(host: "https://irc.pleroma.social");
//    LoungeConnectionPreferences(host: "http://192.168.0.103:9000/");
//    LoungeConnectionPreferences(host: "http://192.168.0.103:9000/");
//LoungePreferences(host: "http://192.168.1.103:9000/");

ChatNetworkPreferences createDefaultIRCNetworkPreferences(
        BuildContext context) =>
    ChatNetworkPreferences(
        ChatNetworkConnectionPreferences(
          serverPreferences: createDefaultNetworkServerPreferences(context),
          userPreferences: createDefaultNetworkUserPreferences(context),
          localId: null,
        ),
        [
          ChatNetworkChannelPreferences.name(
              name: "#thelounge-spam", password: "")
        ]);

ChatNetworkUserPreferences createDefaultNetworkUserPreferences(
        BuildContext context) =>
    ChatNetworkUserPreferences(
        username: "AppIRC User name",
        realName: "AppIRC Real Name",
        nickname: "AppIRCNick");

ChatNetworkServerPreferences createDefaultNetworkServerPreferences(
    BuildContext context) {
  return ChatNetworkServerPreferences(
      serverPort: "6697",
      useTls: true,
      name: "Freenode",
      serverHost: "chat.freenode.net",
      useOnlyTrustedCertificates: true);
}
