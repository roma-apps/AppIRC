import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/pushes/push_service.dart';

var _logger = MyLogger(logTag: "ChatPushesService", enabled: true);

class ChatPushesService extends Providable {
  final PushesService pushesService;
  final ChatInputBackendService backendService;
  ChatPushesService(this.pushesService, this.backendService) {
    addDisposable(streamSubscription:
        backendService.connectionStateStream.listen((connectionState) {
      var token = pushesService.token;
      if (token != null && connectionState == ChatConnectionState.CONNECTED) {
        backendService.onNewDevicePushToken(token);
      }
    }));
    addDisposable(streamSubscription: pushesService.tokenStream.listen((token) {
      if (token != null &&
          backendService.connectionState == ChatConnectionState.CONNECTED) {
        backendService.onNewDevicePushToken(token);
      }
    }));

    addDisposable(
        streamSubscription: pushesService.messageStream.listen((pushMessage) {
      _logger.d(() => "onNewMessage $pushMessage");
    }));
  }
}
