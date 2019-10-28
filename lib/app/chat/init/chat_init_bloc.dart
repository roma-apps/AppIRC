import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "chat_init_bloc.dart", enabled: true);

class ChatInitBloc extends Providable {
  final ChatBackendService _backendService;
  final ChatConnectionBloc _connectionBloc;
  final NetworkListBloc _networksListBloc;
  final ChatPreferences _startPreferences;

  bool get isInitNotStarted => state == ChatInitState.notStarted;

  bool get isInitInProgress => state == ChatInitState.inProgress;

  bool get isInitFinished => state == ChatInitState.finished;

  // ignore: close_sinks
  BehaviorSubject<ChatInitState> _stateSubject =
      BehaviorSubject(seedValue: ChatInitState.notStarted);

  Stream<ChatInitState> get stateStream => _stateSubject.stream;

  ChatInitState get state => _stateSubject.value;

  ChatInitBloc(this._backendService, this._connectionBloc,
      this._networksListBloc, this._startPreferences) {
    addDisposable(subject: _stateSubject);

    var isConnected = _connectionBloc.isConnected;
    _logger.d(() => "init $_startPreferences"
        "isConnected $isConnected");
    if (isConnected) {
      _sendStartRequests();
    } else {
      // ignore: cancel_subscriptions
      _subscribeForConnectEvent();
    }
  }

  void _subscribeForConnectEvent() {
    _logger.d(() => "_subscribeForConnectEvent");
    // ignore: cancel_subscriptions
    StreamSubscription<bool> subscription;
    subscription = _backendService.chatConfigExistStream.listen((configExist) {
      _logger.d(() => "_subscribeForConnectEvent configExist $configExist");
      if (configExist) {
        _sendStartRequests();
        subscription.cancel();
      }
    });

    addDisposable(streamSubscription: subscription);
  }

  void _sendStartRequests() async {
    _logger.d(() => "_sendStartRequests $state");
    if (isInitNotStarted) {
      _logger.d(() => "_sendStartRequests $state");
      _stateSubject.add(ChatInitState.inProgress);

      // server restores state automatically in private mode
      if (_backendService.chatConfig.public) {
        for (var network in _startPreferences.networks) {
          await _backendService.joinNetwork(network, waitForResult: true);
        }
      } else {
        for (var network
            in _backendService.chatInit?.networksWithState ??= []) {
          await _networksListBloc.onNetworkJoined(network);
        }
      }
      _stateSubject.add(ChatInitState.finished);
    }
  }
}
