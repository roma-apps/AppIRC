import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:rxdart/subjects.dart';

var _logger = MyLogger(logTag: "push_service.dart", enabled: true);

class PushesService extends Providable {
  FirebaseMessaging _fcm;

  // ignore: close_sinks
  final BehaviorSubject<String> _tokenSubject = BehaviorSubject();

  Stream<String> get tokenStream => _tokenSubject.stream;

  String get token => _tokenSubject.value;

  // ignore: close_sinks
  final BehaviorSubject<PushMessage> _messageSubject = BehaviorSubject();

  Stream<PushMessage> get messageStream => _messageSubject.stream;

  PushesService() {
    addDisposable(subject: _tokenSubject);
    addDisposable(subject: _messageSubject);
  }

  init() async {
    _fcm = FirebaseMessaging();
    _logger.d(() => "init");
  }

  configure() async {
    _logger.d(() => "configure");
    addDisposable(streamSubscription: _fcm.onTokenRefresh.listen((newToken) {
      _onNewToken(newToken);
    }));

    _fcm.configure(
        onMessage: (data) async =>
            _onNewMessage(PushMessage(PushMessageType.foreground, data)),
        onLaunch: (data) async =>
            _onNewMessage(PushMessage(PushMessageType.launch, data)),
        onResume: (data) async =>
            _onNewMessage(PushMessage(PushMessageType.resume, data)));

    _fcm.setAutoInitEnabled(true);

    await _updateToken();
  }

  void _onNewToken(String newToken) {
    _logger.d(() => "newToken $newToken");
    _tokenSubject.add(newToken);
  }

  void _onNewMessage(PushMessage pushMessage) {
    _logger.d(() => "pushMessage $pushMessage");
    _messageSubject.add(pushMessage);
  }

  Future _updateToken() async {
    var token = await _fcm.getToken();
    if (token != null) {
      _onNewToken(token);
    }
  }

  askPermissions() async {
    // TODO: show ios dialog with own dialog. Add option to settings
    _fcm.requestNotificationPermissions(IosNotificationSettings());
  }
}
