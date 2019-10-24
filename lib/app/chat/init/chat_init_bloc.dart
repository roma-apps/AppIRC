import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/preferences/chat_preferences_model.dart';
import 'package:flutter_appirc/app/chat/state/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/state/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "ChatInitBloc", enabled: true);

class ChatInitBloc extends Providable {
  final ChatInputBackendService _backendService;
  final ChatConnectionBloc _connectionBloc;
  final ChatNetworksListBloc _networksListBloc;
  final ChatPreferences _startPreferences;

  bool get isInitNotStarted => state == ChatInitState.NOT_STARTED;

  bool get isInitInProgress => state == ChatInitState.IN_PROGRESS;

  bool get isInitFinished => state == ChatInitState.FINISHED;

  // ignore: close_sinks
  BehaviorSubject<ChatInitState> _stateController = BehaviorSubject(
      seedValue: ChatInitState.NOT_STARTED);

  Stream<ChatInitState> get stateStream => _stateController.stream;

  ChatInitState get state => _stateController.value;

  ChatInitBloc(this._backendService, this._connectionBloc,
      this._networksListBloc, this._startPreferences) {
    _logger.d(() => "init $_startPreferences");
    addDisposable(subject: _stateController);

    if (_connectionBloc.isConnected) {
      _sendStartRequests();
    } else {
      // ignore: cancel_subscriptions
      StreamSubscription<ChatConnectionState> subscription;
      subscription =
          _connectionBloc.connectionStateStream.listen((connectionState) {
            _logger.d(() => "send ${_connectionBloc
                .isConnected} connectionState $connectionState");
            if (_connectionBloc.isConnected) {
              _sendStartRequests();
              subscription.cancel();
            }
          });

      addDisposable(streamSubscription: subscription);
    }
  }

  void _sendStartRequests() async {
    _logger.d(() => "_sendStartRequests $state");
    if (isInitNotStarted) {
      _logger.d(() => "_sendStartRequests $state");
      _stateController.add(ChatInitState.IN_PROGRESS);

      // server restores state automatically in private mode
      if (_backendService.chatConfig.public) {

        for(var network in _startPreferences.networks) {
          await _backendService.joinNetwork(network, waitForResult: true);
        }
      } else {
        for(var network in _backendService.chatInit?.networksWithState ??= []) {
          await _networksListBloc.onNetworkJoined(network);
        }
      }
      _stateController.add(ChatInitState.FINISHED);
    }
  }
}
