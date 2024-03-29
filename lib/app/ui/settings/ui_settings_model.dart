import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/settings/settings_model.dart';
import 'package:flutter_appirc/json/json_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ui_settings_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UiSettings implements IJsonObject, ISettings<UiSettings>  {
  @JsonKey(name: "theme_id")
  final String themeId;

  UiSettings({
    @required this.themeId,
  });

  factory UiSettings.fromJson(Map<String, dynamic> json) =>
      _$UiSettingsFromJson(json);

  factory UiSettings.fromJsonString(String jsonString) =>
      _$UiSettingsFromJson(jsonDecode(jsonString));

  static List<UiSettings> listFromJsonString(String str) =>
      List<UiSettings>.from(
          json.decode(str).map((x) => UiSettings.fromJson(x)));

  @override
  Map<String, dynamic> toJson() => _$UiSettingsToJson(this);

  String toJsonString() => jsonEncode(_$UiSettingsToJson(this));

  @override
  UiSettings clone() => copyWith();

  UiSettings copyWith({
    String themeId,
    String statusFontSize,
  }) =>
      UiSettings(
        themeId: themeId ?? this.themeId,
      );

  @override
  String toString() => 'UiSettings{themeId: $themeId}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiSettings &&
          runtimeType == other.runtimeType &&
          themeId == other.themeId;

  @override
  int get hashCode => themeId.hashCode;
}
