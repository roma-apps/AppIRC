import 'package:flutter/foundation.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'irc_networks_model.g.dart';

@JsonSerializable()
class IRCNetworksPreferences extends Preferences {
  final List<IRCNetworkPreferences> networks;

  IRCNetworksPreferences(this.networks);

  @override
  String toString() {
    return 'IRCNetworksConnectionPreferences{networks: $networks}';
  }

  @override
  Map<String, dynamic> toJson() => _$IRCNetworksPreferencesToJson(this);

  factory IRCNetworksPreferences.fromJson(Map<String, dynamic> json) =>
      _$IRCNetworksPreferencesFromJson(json);
}
