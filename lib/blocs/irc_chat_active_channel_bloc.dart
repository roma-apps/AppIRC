import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCChatBloc", enabled: true);

class IRCChatActiveChannelBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworksListBloc networksListBloc;

  IRCNetworkChannel _activeChannel;
  final BehaviorSubject<IRCNetworkChannel> _activeChannelController =
      new BehaviorSubject<IRCNetworkChannel>();

  StreamSubscription<List<IRCNetwork>> _networksSubscription;

  Stream<IRCNetworkChannel> get activeChannelStream =>
      _activeChannelController.stream;

  IRCChatActiveChannelBloc(this._lounge, {@required this.networksListBloc}) {
    _logger.i(() => "start creating");

    _networksSubscription = networksListBloc.networksStream
        .listen((newNetworks) async => _onNetworksListChanged());

    _logger.i(() => "stop creating");
  }

  void _onNetworksListChanged() {
    if (_activeChannel == null) {
      var allChannels = networksListBloc.allNetworksChannels;
      if (allChannels.isNotEmpty) {
        changeActiveChanel(allChannels.first);
      }
    }
  }

  void dispose() {
    _activeChannelController.close();
    _networksSubscription.cancel();
  }

  changeActiveChanel(IRCNetworkChannel newActiveChannel) async {
    if (_activeChannel == newActiveChannel) {
      return;
    }

    _logger.i(() => "changeActiveChanel $changeActiveChanel");
    _activeChannel = newActiveChannel;
    _activeChannelController.sink.add(newActiveChannel);

    await _lounge.sendOpenRequest(newActiveChannel);
    await _lounge.sendNamesRequest(newActiveChannel);
  }
}
