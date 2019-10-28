// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_server_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkServerPreferences _$NetworkServerPreferencesFromJson(
    Map<String, dynamic> json) {
  return NetworkServerPreferences(
    name: json['name'] as String,
    serverHost: json['serverHost'] as String,
    serverPort: json['serverPort'] as String,
    useTls: json['useTls'] as bool,
    useOnlyTrustedCertificates: json['useOnlyTrustedCertificates'] as bool,
  );
}

Map<String, dynamic> _$NetworkServerPreferencesToJson(
        NetworkServerPreferences instance) =>
    <String, dynamic>{
      'name': instance.name,
      'serverHost': instance.serverHost,
      'serverPort': instance.serverPort,
      'useTls': instance.useTls,
      'useOnlyTrustedCertificates': instance.useOnlyTrustedCertificates,
    };
