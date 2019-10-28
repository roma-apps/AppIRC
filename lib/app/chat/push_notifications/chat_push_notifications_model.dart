
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_push_notifications_model.g.dart';

@JsonSerializable()
class ChatPushMessageNotification {
  final String title;
  final String body;
  ChatPushMessageNotification(this.title, this.body);

  @override
  String toString() {
    return 'ChatPushMessageNotification{title: $title, body: $body}';
  }

  Map<String, dynamic> toJson() => _$ChatPushMessageNotificationToJson(this);

  factory ChatPushMessageNotification.fromJson(Map<dynamic, dynamic> json) =>
      _$ChatPushMessageNotificationFromJson(json);
}

class ChatPushMessage {
  final PushMessageType type;
  final ChatPushMessageNotification notification;
  final ChatPushMessageData data;
  ChatPushMessage(this.type, this.notification, this.data);

  @override
  String toString() {
    return 'ChatPushMessage{type: $type, notification: $notification,'
        ' data: $data}';
  }
}


@JsonSerializable()
class ChatPushMessageData {
  final String chanId;
  final String body;
  final String type;
  final String timestamp;
  final String title;
  ChatPushMessageData(
      this.chanId, this.body, this.type, this.timestamp, this.title);

  @override
  String toString() {
    return 'ChatPushMessageData{chanId: $chanId, body: $body,'
        ' type: $type, timestamp: $timestamp, title: $title}';
  }

  factory ChatPushMessageData.fromJson(Map<dynamic, dynamic> json) =>
      _$ChatPushMessageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ChatPushMessageDataToJson(this);
}