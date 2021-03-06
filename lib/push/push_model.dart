import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/enum/enum_values.dart';
import 'package:json_annotation/json_annotation.dart';

part 'push_model.g.dart';

typedef dynamic PushMessageListener(PushMessage message);

@JsonSerializable(explicitToJson: true)
class PushMessage {
  PushMessageType get type =>
      _pushMessageTypeEnumValues.valueToEnumMap[typeString];

  final PushNotification notification;

  final Map<String, dynamic> data;

  final String typeString;

  bool get isLaunchOrResume =>
      type == PushMessageType.launch || type == PushMessageType.resume;

  PushMessage({
    @required this.typeString,
    @required this.notification,
    @required this.data,
  });

  @override
  String toString() {
    return 'PushMessage{type: $type,'
        ' notification: $notification,'
        ' data: $data}';
  }

  PushMessage copyWith({
    PushNotification notification,
    Map<String, dynamic> data,
    String typeString,
  }) =>
      PushMessage(
        notification: notification ?? this.notification,
        data: data ?? this.data,
        typeString: typeString ?? this.typeString,
      );

  factory PushMessage.fromJson(Map<String, dynamic> json) =>
      _$PushMessageFromJson(json);

  factory PushMessage.fromJsonString(String jsonString) =>
      _$PushMessageFromJson(jsonDecode(jsonString));

  static List<PushMessage> listFromJsonString(String str) =>
      List<PushMessage>.from(
          json.decode(str).map((x) => PushMessage.fromJson(x)));

  Map<String, dynamic> toJson() => _$PushMessageToJson(this);

  String toJsonString() => jsonEncode(_$PushMessageToJson(this));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PushMessage &&
          runtimeType == other.runtimeType &&
          notification == other.notification &&
          data == other.data &&
          typeString == other.typeString;

  @override
  int get hashCode =>
      notification.hashCode ^ data.hashCode ^ typeString.hashCode;
}

enum PushMessageType {
  foreground,
  launch,
  resume,
}

extension PushMessageTypeJsonValueExtension on PushMessageType {
  String toJsonValue() => _pushMessageTypeEnumValues.enumToValueMap[this];
}

extension PushMessageTypeStringExtension on String {
  PushMessageType toPushMessageType() {
    var visibility = _pushMessageTypeEnumValues.valueToEnumMap[this];
    assert(visibility != null, "invalid visibility $this");
    return visibility;
  }
}

EnumValues<PushMessageType> _pushMessageTypeEnumValues = EnumValues({
  "foreground": PushMessageType.foreground,
  "launch": PushMessageType.launch,
  "resume": PushMessageType.resume,
});

@JsonSerializable(
  explicitToJson: true,
)
class PushNotification {
  final String title;

  final String body;

  PushNotification({
    @required this.title,
    @required this.body,
  });

  @override
  String toString() {
    return 'PushNotification{title: $title, body: $body}';
  }

  Map<String, dynamic> toJson() => _$PushNotificationToJson(this);

  factory PushNotification.fromJson(Map<dynamic, dynamic> json) =>
      _$PushNotificationFromJson(json);
}
