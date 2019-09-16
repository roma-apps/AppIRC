import 'dart:async';

import 'package:flutter_appirc/blocs/irc_network_state_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

class IRCNetworkChannelUnreadCountBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;


  var _unreadCountController = BehaviorSubject<int>(
      seedValue: 0);

  StreamSubscription<IRCNetworkChannel> openChannelSubscription;
  StreamSubscription<MessageLoungeResponseBody> msgSubscription;



  Stream<int> get unreadCountStream =>
      _unreadCountController.stream;

  IRCNetworkChannelUnreadCountBloc(this._lounge, this.channel) {

    msgSubscription =
        _lounge.messagesStream.listen((msgLounge) {

          if(msgLounge.chan == channel.remoteId) {
            if(msgLounge.unread != null) {
              _unreadCountController.add(msgLounge.unread);
            }
          }

    });

    openChannelSubscription = _lounge.openRequestStream.listen((openedChannel) {
      if(openedChannel == channel) {
        _unreadCountController.add(0);
      }
    });


  }

  @override
  void dispose() {
    _unreadCountController.close();
    msgSubscription.cancel();
    openChannelSubscription.cancel();
//    networkSubscription.cancel();
//    joinChannelSubscription.cancel();

  }
}
