import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

var _logger = MyLogger(logTag: "ChatInitBloc", enabled: true);

class ChatInitBloc extends Providable {
  final ChatInputBackendService _backendService;
  final ChatConnectionBloc _connectionBloc;
  final ChatPreferences _startPreferences;

  bool initStarted = false;

  ChatInitBloc(
      this._backendService, this._connectionBloc, this._startPreferences) {

    _logger.d(()=>"init $_startPreferences");

    if (_connectionBloc.isConnected) {
      _sendStartRequests();
    } else {
      // ignore: cancel_subscriptions
      StreamSubscription<ChatConnectionState> subscription;
      subscription =
          _connectionBloc.connectionStateStream.listen((connectionState) {

            _logger.d(()=>"send ${_connectionBloc.isConnected} connectionState $connectionState");
            if (_connectionBloc.isConnected) {
              _sendStartRequests();
              subscription.cancel();
            }
          });

      addDisposable(streamSubscription: subscription);
    }
  }

  void _sendStartRequests() {
    initStarted = true;
    _startPreferences.networks.forEach((network) async {
      await _backendService.joinNetwork(network);
    });
  }


}
