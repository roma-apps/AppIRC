import 'dart:io';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:flutter_appirc/pushes/push_service.dart';
import 'package:logging/logging.dart';

var _logger = Logger("chat_push_notifications.dart");

final String _iosPushMessageNotificationKey = "notification";
final String _iosPushMessageDataKey = "data";

class ChatPushesService extends DisposableOwner {
  final PushesService _pushesService;
  final ChatBackendService _backendService;
  final ChatInitBloc _chatInitBloc;

  Stream<ChatPushMessage> get chatPushMessageStream =>
      _pushesService.messageStream.map(
        (pushMessage) {
          Map<String, dynamic> data = _remapToStringObjectMap(pushMessage);

          if (Platform.isIOS) {
            return _parseChatPushMessageOnAndroid(pushMessage, data);
          } else if (Platform.isAndroid) {
            return _parseChatPushMessageOnIOS(data, pushMessage);
          } else {
            throw Exception("Platform not supported");
          }
        },
      );

  Map<String, dynamic> _remapToStringObjectMap(PushMessage pushMessage) {
    return pushMessage.data
        .map((key, value) => MapEntry(key.toString(), value));
  }

  ChatPushMessage _parseChatPushMessageOnIOS(
    Map<String, dynamic> data,
    PushMessage pushMessage,
  ) {
    // ios notification always have own format

    var messageNotification = _remapForJson(
      data[_iosPushMessageNotificationKey],
    );
    var messageData = _remapForJson(
      data[_iosPushMessageDataKey],
    );
    return ChatPushMessage(
      pushMessage.type,
      messageNotification?.isNotEmpty == true
          ? ChatPushMessageNotification.fromJson(messageNotification)
          : null,
      messageData?.isNotEmpty == true
          ? ChatPushMessageData.fromJson(messageData)
          : null,
    );
  }

  ChatPushMessage _parseChatPushMessageOnAndroid(
    PushMessage pushMessage,
    Map<String, dynamic> data,
  ) {
    return ChatPushMessage(
      pushMessage.type,
      data?.isNotEmpty == true
          ? ChatPushMessageNotification.fromJson(data)
          : null,
      data?.isNotEmpty == true ? ChatPushMessageData.fromJson(data) : null,
    );
  }

  // Json serialization accepts Map<String, dynamic>
  // but we have Map<dynamic, dynamic> originally
  Map<String, dynamic> _remapForJson(raw) => (raw as Map)
      ?.map((key, value) => MapEntry<String, dynamic>(key.toString(), value));

  ChatPushesService(
      this._pushesService, this._backendService, this._chatInitBloc) {
    addDisposable(
      streamSubscription: _chatInitBloc.stateStream.listen(
        (newState) {
          if (newState == ChatInitState.finished) {
            var token = _pushesService.token;
            if (token != null) {
              _backendService.sendDevicePushFCMTokenToServer(token);
            }
          }
        },
      ),
    );

    addDisposable(
      streamSubscription: _backendService.connectionStateStream.listen(
        (connectionState) {
          var token = _pushesService.token;

          if (token != null &&
              connectionState == ChatConnectionState.connected) {
            _backendService.sendDevicePushFCMTokenToServer(token);
          }
        },
      ),
    );
    addDisposable(
      streamSubscription: _pushesService.tokenStream.listen(
        (token) {
          if (token != null &&
              _backendService.connectionState ==
                  ChatConnectionState.connected) {
            _backendService.sendDevicePushFCMTokenToServer(token);
          }
        },
      ),
    );

    addDisposable(
      streamSubscription: _pushesService.messageStream.listen(
        (pushMessage) {
          _logger.fine(() => "newPushMessage $pushMessage");
        },
      ),
    );
  }
}
