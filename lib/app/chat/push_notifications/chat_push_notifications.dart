import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/push/fcm/fcm_push_service.dart';
import 'package:logging/logging.dart';

var _logger = Logger("chat_push_notifications.dart");

class ChatPushesService extends DisposableOwner {
  final IFcmPushService fcmPushService;
  final ChatBackendService backendService;
  final ChatInitBloc chatInitBloc;

  Stream<ChatPushMessage> get chatPushMessageStream =>
      fcmPushService.messageStream.map(
        (pushMessage) => ChatPushMessage(
          pushMessage.type,
          pushMessage.data?.isNotEmpty == true
              ? ChatPushMessageNotification.fromJson(pushMessage.data)
              : null,
          pushMessage.data?.isNotEmpty == true
              ? ChatPushMessageData.fromJson(pushMessage.data)
              : null,
        ),
      );

  ChatPushesService({
    @required this.fcmPushService,
    @required this.backendService,
    @required this.chatInitBloc,
  }) {
    addDisposable(
      streamSubscription: chatInitBloc.stateStream.listen(
        (newState) {
          if (newState == ChatInitState.finished) {
            var token = fcmPushService.deviceToken;
            if (token != null) {
              backendService.sendDevicePushFCMTokenToServer(newToken: token);
            }
          }
        },
      ),
    );

    addDisposable(
      streamSubscription: backendService.connectionStateStream.listen(
        (connectionState) {
          var token = fcmPushService.deviceToken;

          if (token != null &&
              connectionState == ChatConnectionState.connected) {
            backendService.sendDevicePushFCMTokenToServer(newToken: token);
          }
        },
      ),
    );
    addDisposable(
      streamSubscription: fcmPushService.deviceTokenStream.listen(
        (token) {
          if (token != null &&
              backendService.connectionState == ChatConnectionState.connected) {
            backendService.sendDevicePushFCMTokenToServer(newToken: token);
          }
        },
      ),
    );

    addDisposable(
      streamSubscription: fcmPushService.messageStream.listen(
        (pushMessage) {
          _logger.fine(() => "newPushMessage $pushMessage");
        },
      ),
    );
  }
}
