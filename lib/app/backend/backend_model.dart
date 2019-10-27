import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/preview/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
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
    return 'ChatPushMessage{type: $type, notification: $notification,'
        ' data: $data}';
  }
}

class ChatLoadMoreData {
  List<ChatMessage> messages;
  bool moreHistoryAvailable;
  ChatLoadMoreData(this.messages, this.moreHistoryAvailable);

  ChatLoadMoreData.name(
      {@required this.messages, @required this.moreHistoryAvailable});
}

class ChannelTogglePreview {
  Network network;
  NetworkChannel networkChannel;
  bool allPreviewsShown;
  ChannelTogglePreview(
      this.network, this.networkChannel, this.allPreviewsShown);

  ChannelTogglePreview.name(
      this.network, this.networkChannel, this.allPreviewsShown);

  @override
  String toString() {
    return 'ChannelTogglePreview{network: $network,'
        ' networkChannel: $networkChannel, allPreviewsShown: $allPreviewsShown}';
  }
}

class MessageTogglePreview {
  Network network;
  NetworkChannel networkChannel;
  RegularMessage message;
  MessagePreview preview;
  bool newShownValue;
  MessageTogglePreview(this.network, this.networkChannel, this.message,
      this.preview, this.newShownValue);

  MessageTogglePreview.name(this.network, this.networkChannel, this.message,
      this.preview, this.newShownValue);

  @override
  String toString() {
    return 'ChatTogglePreview{network: $network, '
        'networkChannel: $networkChannel, message: $message,'
        ' preview: $preview, newShownValue: $newShownValue}';
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

  Map<String, dynamic> toJson() => _$ChatPushMessageNotificationToJson(this);

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

  Map<String, dynamic> toJson() => _$ChatPushMessageDataToJson(this);
}

class RequestResult<T> {
  final bool isSentSuccessfully;
  final T result;

  RequestResult(this.isSentSuccessfully, this.result);

  RequestResult.name(
      {@required this.isSentSuccessfully, @required this.result});

  @override
  String toString() {
    return 'RequestResult{isSentSuccessfully: $isSentSuccessfully,'
        ' result: $result}';
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
