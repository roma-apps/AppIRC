import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_model.dart';
import 'package:flutter_appirc/json/json_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_preferences_model.g.dart';

@JsonSerializable()
class NetworkPreferences extends IJsonObject {
  static const String channelsSeparator = " ";

  int get localId => networkConnectionPreferences?.localId;

  int get localIdOrUndefined => localId ?? -1;

  NetworkConnectionPreferences networkConnectionPreferences;

  final List<ChannelPreferences> channels;

  NetworkPreferences(
    this.networkConnectionPreferences,
    this.channels,
  );

  @override
  String toString() {
    return 'ChatNetworkPreferences{'
        'networkConnectionPreferences: $networkConnectionPreferences, '
        'channels: $channels'
        '}';
  }

  @JsonKey(ignore: true)
  List<ChannelPreferences> get channelsWithoutPassword => channels
      .where(
          (channel) => (channel.password == null || channel.password.isEmpty))
      .toList();

  @JsonKey(ignore: true)
  List<ChannelPreferences> get channelsWithPassword => channels
      .where((channel) =>
          (channel.password != null && channel.password.isNotEmpty))
      .toList();

  factory NetworkPreferences.fromJson(Map<String, dynamic> json) =>
      _$NetworkPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NetworkPreferencesToJson(this);
}

@JsonSerializable()
class NetworkConnectionPreferences extends IJsonObject {
  int localId;

  final NetworkServerPreferences serverPreferences;
  final NetworkUserPreferences userPreferences;

  NetworkConnectionPreferences({
    @required this.serverPreferences,
    @required this.userPreferences,
    this.localId,
  });

  String get name => serverPreferences.name;

  @override
  String toString() {
    return 'NetworkConnectionPreferences{'
        'localId: $localId, '
        'serverPreferences: $serverPreferences, '
        'userPreferences: $userPreferences'
        '}';
  }

  factory NetworkConnectionPreferences.fromJson(Map<String, dynamic> json) =>
      _$NetworkConnectionPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NetworkConnectionPreferencesToJson(this);
}
