// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushMessage _$PushMessageFromJson(Map<String, dynamic> json) {
  return PushMessage(
    typeString: json['typeString'] as String,
    notification: json['notification'] == null
        ? null
        : PushNotification.fromJson(
            json['notification'] as Map<String, dynamic>),
    data: json['data'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$PushMessageToJson(PushMessage instance) =>
    <String, dynamic>{
      'notification': instance.notification?.toJson(),
      'data': instance.data,
      'typeString': instance.typeString,
    };

PushNotification _$PushNotificationFromJson(Map<String, dynamic> json) {
  return PushNotification(
    title: json['title'] as String,
    body: json['body'] as String,
  );
}

Map<String, dynamic> _$PushNotificationToJson(PushNotification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
    };
