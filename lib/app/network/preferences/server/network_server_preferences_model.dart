import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/json/json_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'network_server_preferences_model.g.dart';

@JsonSerializable()
class NetworkServerPreferences extends IJsonObject {
  String name;
  String serverHost;
  String serverPort;
  bool useTls;
  bool useOnlyTrustedCertificates;

  NetworkServerPreferences({
    @required this.name,
    @required this.serverHost,
    @required this.serverPort,
    @required this.useTls,
    @required this.useOnlyTrustedCertificates,
  });

  @override
  String toString() {
    return 'ChatNetworkServerPreferences{'
        'name: $name, '
        'serverHost: $serverHost, '
        'serverPort: $serverPort, '
        'useTls: $useTls, '
        'useOnlyTrustedCertificates: $useOnlyTrustedCertificates'
        '}';
  }

  factory NetworkServerPreferences.fromJson(Map<String, dynamic> json) =>
      _$NetworkServerPreferencesFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NetworkServerPreferencesToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkServerPreferences &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          serverHost == other.serverHost &&
          serverPort == other.serverPort &&
          useTls == other.useTls &&
          useOnlyTrustedCertificates == other.useOnlyTrustedCertificates;

  @override
  int get hashCode =>
      name.hashCode ^
      serverHost.hashCode ^
      serverPort.hashCode ^
      useTls.hashCode ^
      useOnlyTrustedCertificates.hashCode;
}
