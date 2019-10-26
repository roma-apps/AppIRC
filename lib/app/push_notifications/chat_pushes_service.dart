import 'dart:io';

import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/state/chat_connection_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/pushes/push_service.dart';

var _logger = MyLogger(logTag: "chat_pushes_service.dart", enabled: true);

class ChatPushesService extends Providable {
  final PushesService _pushesService;
  final ChatBackendService _backendService;

  Stream<ChatPushMessage> get chatPushMessageStream =>
      _pushesService.messageStream.map((pushMessage) {
        Map<String, dynamic> data = pushMessage.data
            .map((key, value) => MapEntry(key.toString(), value));

        if(Platform.isIOS) {


          return ChatPushMessage(
              pushMessage.type,
              data?.isNotEmpty == true
                  ? ChatPushMessageNotification.fromJson(data)
                  : null,
              data?.isNotEmpty == true
                  ? ChatPushMessageData.fromJson(data)
                  : null);
        } else if(Platform.isAndroid) {

        var messageNotification = remapForJson(data["notification"]);
        var messageData = remapForJson(data["data"]);
        return ChatPushMessage(
            pushMessage.type,
            messageNotification?.isNotEmpty == true
                ? ChatPushMessageNotification.fromJson(messageNotification)
                : null,
            messageData?.isNotEmpty == true
                ? ChatPushMessageData.fromJson(messageData)
                : null);
        } else {
          throw Exception("Platform not supported");
        }
      });

  // Json serialization accepts Map<String, dynamic>
  // but we have Map<dynamic, dynamic> originally
  Map<String, dynamic> remapForJson(raw) => (raw as Map)?.map((key, value) =>
      MapEntry<String,
      dynamic>(key.toString(),
      value));

  ChatPushesService(this._pushesService, this._backendService) {
    addDisposable(streamSubscription:
        _backendService.connectionStateStream.listen((connectionState) {
      var token = _pushesService.token;
      if (token != null && connectionState == ChatConnectionState.CONNECTED) {
        _backendService.sendDevicePushFCMTokenToServer(token);
      }
    }));
    addDisposable(
        streamSubscription: _pushesService.tokenStream.listen((token) {
      if (token != null &&
          _backendService.connectionState == ChatConnectionState.CONNECTED) {
        _backendService.sendDevicePushFCMTokenToServer(token);
      }
    }));

    addDisposable(
        streamSubscription: _pushesService.messageStream.listen((pushMessage) {
      _logger.d(() => "newPushMessage $pushMessage");
    }));
  }
}
