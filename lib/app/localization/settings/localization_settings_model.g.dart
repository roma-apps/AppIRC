// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalizationSettings _$LocalizationSettingsFromJson(Map<String, dynamic> json) {
  return LocalizationSettings(
    localizationLocale: json['localization_locale'] == null
        ? null
        : LocalizationLocale.fromJson(
            json['localization_locale'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LocalizationSettingsToJson(
        LocalizationSettings instance) =>
    <String, dynamic>{
      'localization_locale': instance.localizationLocale?.toJson(),
    };
