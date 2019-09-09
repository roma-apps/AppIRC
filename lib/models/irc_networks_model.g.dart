// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'irc_networks_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IRCNetworksPreferences _$IRCNetworksPreferencesFromJson(
    Map<String, dynamic> json) {
  return IRCNetworksPreferences(
    (json['networks'] as List)
        ?.map((e) => e == null
            ? null
            : IRCNetworkPreferences.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$IRCNetworksPreferencesToJson(
        IRCNetworksPreferences instance) =>
    <String, dynamic>{
      'networks': instance.networks,
    };
