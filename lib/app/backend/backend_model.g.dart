// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatPushMessageNotification _$ChatPushMessageNotificationFromJson(
    Map<String, dynamic> json) {
  return ChatPushMessageNotification(
    json['title'] as String,
    json['body'] as String,
  );
}

Map<String, dynamic> _$ChatPushMessageNotificationToJson(
        ChatPushMessageNotification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
    };

ChatPushMessageData _$ChatPushMessageDataFromJson(Map<String, dynamic> json) {
  return ChatPushMessageData(
    json['chanId'] as String,
    json['body'] as String,
    json['type'] as String,
    json['timestamp'] as String,
    json['title'] as String,
  );
}

Map<String, dynamic> _$ChatPushMessageDataToJson(
        ChatPushMessageData instance) =>
    <String, dynamic>{
      'chanId': instance.chanId,
      'body': instance.body,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'title': instance.title,
    };
