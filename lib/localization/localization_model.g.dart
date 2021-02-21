// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalizationLocale _$LocalizationLocaleFromJson(Map<String, dynamic> json) {
  return LocalizationLocale(
    languageCode: json['languageCode'] as String,
    scriptCode: json['scriptCode'] as String,
    countryCode: json['countryCode'] as String,
  );
}

Map<String, dynamic> _$LocalizationLocaleToJson(LocalizationLocale instance) =>
    <String, dynamic>{
      'languageCode': instance.languageCode,
      'scriptCode': instance.scriptCode,
      'countryCode': instance.countryCode,
    };
