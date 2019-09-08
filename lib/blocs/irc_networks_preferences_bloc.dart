import 'package:flutter_appirc/blocs/preferences_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/service/preferences_service.dart';

const _key = "irc_networks";

const List<String> defaultChannels = ["#lounge-spam"];

IRCNetworksPreferences createDefaultIRCNetworksPreferences() => IRCNetworksPreferences([
      createDefaultIRCNetworkPreferences()
    ]);

IRCNetworkPreferences createDefaultIRCNetworkPreferences() => IRCNetworkPreferences(
        networkPreferences: createDefaultNetworkServerPreferences(),
        userPreferences: createDefaultNetworkUserPreferences(),
        channels: defaultChannels);

IRCNetworkUserPreferences createDefaultNetworkUserPreferences() {
  return IRCNetworkUserPreferences(
      username: "AppIRC", realName: "AppIRC", nickname: "AppIRC");
}

IRCNetworkServerPreferences createDefaultNetworkServerPreferences() {
  return IRCNetworkServerPreferences(
      serverPort: "6697",
      useTls: true,
      name: "Freenode",
      serverHost: "chat.freenode.net",
      useOnlyTrustedCertificates: true);
}

IRCNetworksPreferences _jsonConverter(Map<String, dynamic> json) =>
    json == null ? null : IRCNetworksPreferences.fromJson(json);

class IRCNetworksPreferencesBloc
    extends PreferencesBloc<IRCNetworksPreferences> {
  IRCNetworksPreferencesBloc(PreferencesService preferencesService,
      {DefaultValueGenerator<IRCNetworksPreferences> defaultValueGenerator =
          createDefaultIRCNetworksPreferences})
      : super(preferencesService, _key, _jsonConverter, defaultValueGenerator);
}
