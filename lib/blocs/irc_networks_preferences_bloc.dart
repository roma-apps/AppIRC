import 'package:flutter_appirc/blocs/preferences_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/preferences_service.dart';

const _preferencesStorageKey = "irc_networks";

IRCNetworksListPreferences createDefaultIRCNetworksPreferences() =>
    IRCNetworksListPreferences(
        networks: [createDefaultIRCNetworkPreferences()]);

IRCNetworkPreferences createDefaultIRCNetworkPreferences() =>
    IRCNetworkPreferences(
        networkConnectionPreferences: IRCNetworkConnectionPreferences(
          serverPreferences: createDefaultNetworkServerPreferences(),
          userPreferences: createDefaultNetworkUserPreferences(), localId: null,
        ),
        channels: [IRCNetworkChannelPreferences(name: "#thelounge-spam", isLobby: false)]);

IRCNetworkUserPreferences createDefaultNetworkUserPreferences() {
  return IRCNetworkUserPreferences(
      username: "AppIRC User name", realName: "AppIRC Real Name", nickname: "AppIRC Nick");
}

IRCNetworkServerPreferences createDefaultNetworkServerPreferences() {
  return IRCNetworkServerPreferences(
      serverPort: "6697",
      useTls: true,
      name: "Freenode",
      serverHost: "chat.freenode.net",
      useOnlyTrustedCertificates: true);
}

IRCNetworksListPreferences _jsonConverter(Map<String, dynamic> json) =>
    IRCNetworksListPreferences.fromJson(json);

class IRCNetworksPreferencesBloc
    extends JsonPreferencesBloc<IRCNetworksListPreferences> {
  IRCNetworksPreferencesBloc(PreferencesService preferencesService,
      {DefaultValueGenerator<IRCNetworksListPreferences> defaultValueGenerator =
          createDefaultIRCNetworksPreferences})
      : super(preferencesService, _preferencesStorageKey, 1, _jsonConverter,
            defaultValueGenerator);
}
