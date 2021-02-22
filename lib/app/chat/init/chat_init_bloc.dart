import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("chat_init_bloc.dart");

class ChatInitBloc extends DisposableOwner {
  final ChatBackendService _backendService;
  final ChatConnectionBloc _connectionBloc;
  final NetworkListBloc _networksListBloc;
  final ChatPreferences _startPreferences;

  bool get isInitNotStarted => state == ChatInitState.notStarted;

  bool get isInitInProgress => state == ChatInitState.inProgress;

  bool get isInitFinished => state == ChatInitState.finished;

  // ignore: close_sinks
  final BehaviorSubject<ChatInitState> _stateSubject =
      BehaviorSubject.seeded(ChatInitState.notStarted);

  Stream<ChatInitState> get stateStream => _stateSubject.stream;

  ChatInitState get state => _stateSubject.value;

  ChatInitBloc(this._backendService, this._connectionBloc,
      this._networksListBloc, this._startPreferences) {
    addDisposable(subject: _stateSubject);

    var isConnected = _connectionBloc.isConnected;
    _logger.fine(() => "init $_startPreferences"
        "isConnected $isConnected");
    if (isConnected) {
      _sendStartRequests();
    } else {
      // ignore: cancel_subscriptions
      _subscribeForConnectEvent();
    }
  }

  void _subscribeForConnectEvent() {
    _logger.fine(() => "_subscribeForConnectEvent");
    // ignore: cancel_subscriptions
    StreamSubscription<bool> subscription;
    subscription =
        _backendService.isChatConfigExistStream.listen((configExist) {
      _logger.fine(() => "_subscribeForConnectEvent configExist $configExist");
      if (configExist) {
        _sendStartRequests();
        subscription.cancel();
      }
    });

    addDisposable(streamSubscription: subscription);
  }

  void _sendStartRequests() async {
    _logger.fine(() => "_sendStartRequests $state");
    if (isInitNotStarted) {
      _logger.fine(() => "_sendStartRequests $state");
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
