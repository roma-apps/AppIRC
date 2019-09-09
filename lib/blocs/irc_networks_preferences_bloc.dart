import 'package:flutter_appirc/blocs/preferences_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/irc_networks_model.dart';
import 'package:flutter_appirc/service/preferences_service.dart';

const _preferencesStorageKey = "irc_networks";

IRCNetworksPreferences createDefaultIRCNetworksPreferences() =>
    IRCNetworksPreferences([createDefaultIRCNetworkPreferences()]);

IRCNetworkPreferences createDefaultIRCNetworkPreferences() =>
    IRCNetworkPreferences(
        serverPreferences: createDefaultNetworkServerPreferences(),
        userPreferences: createDefaultNetworkUserPreferences());

IRCNetworkUserPreferences createDefaultNetworkUserPreferences() {
  return IRCNetworkUserPreferences(
      username: "AppIRC",
      realName: "AppIRC",
      nickname: "AppIRC",
      channels: ["#lounge-spam"]);
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
    IRCNetworksPreferences.fromJson(json);

class IRCNetworksPreferencesBloc
    extends PreferencesBloc<IRCNetworksPreferences> {
  IRCNetworksPreferencesBloc(PreferencesService preferencesService,
      {DefaultValueGenerator<IRCNetworksPreferences> defaultValueGenerator =
          createDefaultIRCNetworksPreferences})
      : super(preferencesService, _preferencesStorageKey, _jsonConverter,
            defaultValueGenerator);
}
