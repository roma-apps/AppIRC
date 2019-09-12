import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCNetworksListBloc", enabled: true);

class IRCNetworksListBloc extends Providable {
  final LoungeService _lounge;

  final Set<IRCNetwork> _networks = Set<IRCNetwork>();

  List<IRCNetworkChannel> get allNetworksChannels {
    var allChannels = List<IRCNetworkChannel>();
    _networks.forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  final BehaviorSubject<List<IRCNetwork>> _networksController =
      new BehaviorSubject<List<IRCNetwork>>(seedValue: []);

  Stream<List<IRCNetwork>> get networksStream => _networksController.stream;

  StreamSubscription<NetworksLoungeResponseBody> _networksSubscription;
  StreamSubscription<JoinLoungeResponseBody> _joinSubscription;

  IRCNetworksListBloc(this._lounge) {
    _logger.i(() => "start creating");

    _networksSubscription = _lounge.networksStream.listen((event) {
      var newNetworks = Set<IRCNetwork>();

      for (var network in event.networks) {
        List<IRCNetworkChannel> newChannels = List();
        var newNetwork = IRCNetwork(network.name, network.uuid, newChannels,
            IRCNetworkStatus(network.status["connected"]));
        for (var loungeChannel in network.channels) {
          newChannels.add(IRCNetworkChannel(
              name: loungeChannel.name,
              remoteId: loungeChannel.id,
              type: detectIRCNetworkChannelType(loungeChannel.type)));
        }
        newNetworks.add(newNetwork);
      }

      _networks.addAll(newNetworks);

      _onNetworksListChanged();
    });

    _joinSubscription = _lounge.joinStream.listen((event) {
      var networkForChannel =
          _networks.firstWhere((network) => network.remoteId == event.network);
      var newChannel =
          IRCNetworkChannel(name: event.chan.name, remoteId: event.chan.id);
      networkForChannel.channels.add(newChannel);
      _onNetworksListChanged();
    });

    _logger.i(() => "stop creating");
  }

  void _onNetworksListChanged() {
    _logger.i(() => "_onNetworksListChanged $_networks");
    _networksController.sink.add(UnmodifiableListView(_networks));
  }

  void dispose() {
    _networksController.close();

    _networksSubscription.cancel();

    _joinSubscription.cancel();
  }
}
