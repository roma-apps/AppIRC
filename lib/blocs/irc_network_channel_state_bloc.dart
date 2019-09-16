import 'dart:async';

import 'package:flutter_appirc/blocs/irc_network_state_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

class IRCNetworkChannelStateBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;
  final IRCNetworkStateBloc networkStateBloc;

  var _channelStateController = BehaviorSubject<IRCNetworkChannelState>(
      seedValue: IRCNetworkChannelState.DISCONNECTED);

  StreamSubscription<ChannelStateLoungeResponseBody> channelStateSubscription;
  StreamSubscription<IRCNetworkState> networkStateSubscription;

  Stream<IRCNetworkChannelState> get channelStateStream =>
      _channelStateController.stream;

  IRCNetworkChannelStateBloc(this._lounge, this.networkStateBloc, this.channel) {

    networkStateSubscription = networkStateBloc.stateStream.listen((networkState) {
      if(networkState == IRCNetworkState.DISCONNECTED) {
        _channelStateController.add(IRCNetworkChannelState.DISCONNECTED);
      }
    });

    channelStateSubscription =
        _lounge.channelStateStream.listen((loungeChannelState) {
          if(loungeChannelState.chan == channel.remoteId) {
            var newState;
            switch(loungeChannelState.state) {
              case ChannelStateLoungeResponseBody.STATE_CONNECTED:
                newState = IRCNetworkChannelState.CONNECTED;
                break;
              case ChannelStateLoungeResponseBody.STATE_DISCONNECTED:
                newState = IRCNetworkChannelState.DISCONNECTED;
                break;
              default:
                throw Exception("Invalid channel state $loungeChannelState");

            }

            _channelStateController.add(newState);
          }

    });

  }

  @override
  void dispose() {
    _channelStateController.close();
    channelStateSubscription.cancel();
    networkStateSubscription.cancel();
  }
}
