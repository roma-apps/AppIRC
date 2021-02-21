import 'dart:convert';

import 'package:flutter_appirc/json/json_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'localization_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocalizationLocale implements IJsonObject {
  String languageCode;
  String scriptCode;
  String countryCode;

  String get localeString {
    var result = "$languageCode";
    if (scriptCode != null) {
      result = "_$scriptCode";
    }
    if (countryCode != null) {
      result = "_$countryCode";
    }
    return result;
  }

  LocalizationLocale({
    this.languageCode,
    this.scriptCode,
    this.countryCode,
  });

  factory LocalizationLocale.fromJson(Map<String, dynamic> json) =>
      _$LocalizationLocaleFromJson(json);

  factory LocalizationLocale.fromJsonString(String jsonString) =>
      _$LocalizationLocaleFromJson(jsonDecode(jsonString));

  static List<LocalizationLocale> listFromJsonString(String str) =>
      List<LocalizationLocale>.from(
          json.decode(str).map((x) => LocalizationLocale.fromJson(x)));

  @override
  Map<String, dynamic> toJson() => _$LocalizationLocaleToJson(this);

  String toJsonString() => jsonEncode(_$LocalizationLocaleToJson(this));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizationLocale &&
          runtimeType == other.runtimeType &&
          languageCode == other.languageCode &&
          scriptCode == other.scriptCode &&
          countryCode == other.countryCode;

  @override
  int get hashCode =>
      languageCode.hashCode ^ scriptCode.hashCode ^ countryCode.hashCode;

  @override
  String toString() {
    return 'LocalizationLocale{'
        'languageCode: $languageCode,'
        ' scriptCode: $scriptCode,'
        ' countryCode: $countryCode'
        '}';
  }
}
