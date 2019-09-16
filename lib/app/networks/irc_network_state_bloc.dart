import 'dart:async';

import 'package:flutter_appirc/app/networks/irc_network_model.dart';

import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class IRCNetworkStateBloc extends Providable {
  final LoungeService lounge;
  final IRCNetwork network;



  var _stateController = BehaviorSubject<IRCNetworkState>(
      seedValue: IRCNetworkState.DISCONNECTED);

  StreamSubscription<NetworkStatusLoungeResponseBody> stateSubscription;

  Stream<IRCNetworkState> get stateStream =>
      _stateController.stream;

  IRCNetworkStateBloc(this.lounge, this.network) {
    stateSubscription =
        lounge.networkStatusStream.listen((loungeNetworkStatus) {
          if(loungeNetworkStatus.network == network.remoteId) {
            var newState;

            if(loungeNetworkStatus.connected) {
              newState = IRCNetworkState.CONNECTED;
            } else {
              newState = IRCNetworkState.DISCONNECTED;
            }

            _stateController.add(newState);
          }

    });
  }

  @override
  void dispose() {
    _stateController.close();
    stateSubscription.cancel();
  }
}
