import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("push_service.dart");

class PushesService extends DisposableOwner {
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

  void init() async {
    _fcm = FirebaseMessaging();
    _logger.fine(() => "init");
  }

  Future configure() async {
    _logger.fine(() => "configure");
    addDisposable(
      streamSubscription: _fcm.onTokenRefresh.listen(
        (newToken) {
          _onNewToken(newToken);
        },
      ),
    );

    _fcm.configure(
        onMessage: (data) async =>
            _onNewMessage(PushMessage(PushMessageType.foreground, data)),
        onLaunch: (data) async =>
            _onNewMessage(PushMessage(PushMessageType.launch, data)),
        onResume: (data) async =>
            _onNewMessage(PushMessage(PushMessageType.resume, data)));

    await _fcm.setAutoInitEnabled(true);

    unawaited(_updateToken());
  }

  void _onNewToken(String newToken) {
    _logger.fine(() => "newToken $newToken");
    _tokenSubject.add(newToken);
  }

  void _onNewMessage(PushMessage pushMessage) {
    _logger.fine(() => "pushMessage $pushMessage");
    _messageSubject.add(pushMessage);
  }

  Future _updateToken() async {
    var token = await _fcm.getToken();
    if (token != null) {
      _onNewToken(token);
    }
  }

  void askPermissions() {
    // TODO: show ios dialog with own dialog. Add option to settings
    _fcm.requestNotificationPermissions(IosNotificationSettings());
  }
}
