import 'dart:math';

import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/json/json_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_preferences_model.g.dart';

@JsonSerializable()
class ChatPreferences extends IJsonObject {
  int get maxNetworkLocalId {
    var maxNetworkLocalId = 0;
    networks.forEach(
      (network) => maxNetworkLocalId = max(
        maxNetworkLocalId,
        network.localId,
      ),
    );
    return maxNetworkLocalId;
  }

  int get maxChannelLocalId {
    var maxChannelLocalId = 0;
    networks.forEach(
      (network) => network.channels.forEach(
        (channel) => maxChannelLocalId = max(
          maxChannelLocalId,
          channel.localId,
        ),
      ),
    );
    return maxChannelLocalId;
  }

  static final empty = ChatPreferences([]);

  List<NetworkPreferences> networks;

  ChatPreferences(this.networks);

  factory ChatPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatPreferencesToJson(this);

  @override
  String toString() {
    return 'ChatPreferences{networks: $networks}';
  }
}
