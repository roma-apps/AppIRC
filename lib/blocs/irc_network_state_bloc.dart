import 'dart:async';

import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
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
