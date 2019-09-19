import 'dart:math';

import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_preferences_model.g.dart';

@JsonSerializable()
class ChatPreferences extends JsonPreferences {
  int get maxNetworkLocalId {
    var maxNetworkLocalId = 0;
    networks.forEach((network) =>
        maxNetworkLocalId = max(maxNetworkLocalId, network.localId));
    return maxNetworkLocalId;
  }

  int get maxNetworkChannelLocalId {
    var maxNetworkChannelLocalId = 0;
    networks.forEach((network) => network.channels.forEach((channel) =>
        maxNetworkChannelLocalId =
            max(maxNetworkChannelLocalId, channel.localId)));
    return maxNetworkChannelLocalId;
  }

  static final empty = ChatPreferences([]);

  final List<IRCNetworkPreferences> networks;

  ChatPreferences(this.networks);

  factory ChatPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatPreferencesToJson(this);
}
