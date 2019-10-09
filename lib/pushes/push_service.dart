import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "PushesService", enabled: true);

class PushesService extends Providable {
  Firestore _db;
  FirebaseMessaging _fcm;

  // ignore: close_sinks
  final BehaviorSubject<String> _tokenController = BehaviorSubject();
  Stream<String> get tokenStream => _tokenController.stream;
  String get token => _tokenController.value;

  // ignore: close_sinks
  final BehaviorSubject<PushMessage> _messageController = BehaviorSubject();
  Stream<PushMessage> get messageStream => _messageController.stream;
  PushesService() {
    addDisposable(subject: _tokenController);
    addDisposable(subject: _messageController);
  }

  init() async {
    _db = Firestore.instance;
    _fcm = FirebaseMessaging();

    _logger.d(() => "init");

    addDisposable(streamSubscription: _fcm.onTokenRefresh.listen((newToken) {
      onNewToken(newToken);
    }));

    _fcm.configure(
        onMessage: (data) async =>
            onNewMessage(PushMessage(PushMessageType.DEFAULT, data)),
//        onBackgroundMessage: (data) async =>
//            onNewMessage(PushMessage(PushMessageType.BACKGROUND, data)),
        onLaunch: (data) async =>
            onNewMessage(PushMessage(PushMessageType.LAUNCH, data)),
        onResume: (data) async =>
            onNewMessage(PushMessage(PushMessageType.RESUME, data)));

    _fcm.setAutoInitEnabled(true);

    await _updateToken();

  }

  void onNewToken(String newToken) {
    _logger.d(() => "newToken $newToken");
    _tokenController.add(newToken);
  }

  void onNewMessage(PushMessage pushMessage) {
    _messageController.add(pushMessage);
    _logger.d(() => "pushMessage $pushMessage");
  }

  Future _updateToken() async {
    var token = await _fcm.getToken();
    assert(token != null);
    onNewToken(token);
  }

  askPermissions() async {
    if (Platform.isIOS) {
//      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
      // save the token  OR subscribe to a topic here
//      }
    }

    _fcm.requestNotificationPermissions(IosNotificationSettings());
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
//    // Get the current user
//    String uid = 'jeffd23';
//    // FirebaseUser user = await _auth.currentUser();
//
//    // Save it to Firestore
//    if (fcmToken != null) {
//      var tokens = _db
//          .collection('users')
//          .document(uid)
//          .collection('tokens')
//          .document(fcmToken);
//
//      await tokens.setData({
//        'token': fcmToken,
//        'createdAt': FieldValue.serverTimestamp(),
//        // optional
//        'platform': Platform.operatingSystem
//        // optional
//      });
//    }
  }
}
