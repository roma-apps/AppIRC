import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'backend_model.g.dart';

class ChatPushMessage {
  final PushMessageType type;
  final ChatPushMessageNotification notification;
  final ChatPushMessageData data;
  ChatPushMessage(this.type, this.notification, this.data);

  @override
  String toString() {
    return 'ChatPushMessage{type: $type, notification: $notification, data: $data}';
  }
}

@JsonSerializable()
class ChatPushMessageNotification {
  final String title;
  final String body;
  ChatPushMessageNotification(this.title, this.body);

  @override
  String toString() {
    return 'ChatPushMessageNotification{title: $title, body: $body}';
  }

  factory ChatPushMessageNotification.fromJson(Map<dynamic, dynamic> json) =>
      _$ChatPushMessageNotificationFromJson(json);
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
}

class RequestResult<T> {
  final bool isSentSuccessfully;
  final T result;

  RequestResult(this.isSentSuccessfully, this.result);

  RequestResult.name(
      {@required this.isSentSuccessfully, @required this.result});

  @override
  String toString() {
    return 'RequestResult{isSentSuccessfully: $isSentSuccessfully, result: $result}';
  }
}

class ConnectResult<T> {
  ChatConfig config;
  ChatInitInformation chatInit;
  bool isSocketConnected = false;
  bool isTimeout = false;
  bool isPrivateModeResponseReceived = false;
  bool isAuthRequestSent = false;
  bool isFailAuthResponseReceived = false;
  dynamic error;
  @override
  String toString() {
    return 'ConnectResult{config: $config, chatInit: $chatInit, '
        'isSocketConnected: $isSocketConnected, isTimeout: $isTimeout,'
        ' isPrivateModeResponseReceived: $isPrivateModeResponseReceived,'
        ' isAuthRequestSent: $isAuthRequestSent,'
        ' isFailAuthResponseReceived: $isFailAuthResponseReceived,'
        ' error: $error}';
  }
}
