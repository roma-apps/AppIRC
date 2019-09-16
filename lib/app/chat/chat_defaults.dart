
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

LoungePreferences createDefaultLoungePreferences(BuildContext context) =>
//    LoungePreferences(host: "https://demo.thelounge.chat/");
//LoungePreferences(host: "https://irc.pleroma.social");
LoungePreferences(host: "http://192.168.0.103:9000/");
//LoungePreferences(host: "http://192.168.1.103:9000/");



IRCNetworkPreferences createDefaultIRCNetworkPreferences(
    BuildContext context) =>
    IRCNetworkPreferences(
        networkConnectionPreferences: IRCNetworkConnectionPreferences(
          serverPreferences: createDefaultNetworkServerPreferences(context),
          userPreferences: createDefaultNetworkUserPreferences(context),
          localId: null,
        ),
        channels: [
          IRCNetworkChannelPreferences(name: "#thelounge-spam", isLobby: false)
        ]);

IRCNetworkUserPreferences createDefaultNetworkUserPreferences(
    BuildContext context) =>
    IRCNetworkUserPreferences(
        username: "AppIRC User name",
        realName: "AppIRC Real Name",
        nickname: "AppIRC Nick");

IRCNetworkServerPreferences createDefaultNetworkServerPreferences(
    BuildContext context) {
  return IRCNetworkServerPreferences(
      serverPort: "6697",
      useTls: true,
      name: "Freenode",
      serverHost: "chat.freenode.net",
      useOnlyTrustedCertificates: true);
}