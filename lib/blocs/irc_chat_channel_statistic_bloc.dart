import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCChatChannelStatisticBloc", enabled: true);

class IRCChatChannelStatisticBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;


  final BehaviorSubject<IRCNetworkChannelStatistics> _channelStatisticsController =
      new BehaviorSubject<IRCNetworkChannelStatistics>();

  Stream<IRCNetworkChannelStatistics> get channelStatistricStream =>
      _channelStatisticsController.stream;

  IRCChatChannelStatisticBloc(this._lounge, {@required this.channel}) {
    _logger.i(() => "start creating");
//
//    _networksSubscription = networksListBloc.networksStream
//        .listen((newNetworks) async => _onNetworksListChanged());

    _logger.i(() => "stop creating");
  }

  void dispose() {
    _channelStatisticsController.close();

  }

}
