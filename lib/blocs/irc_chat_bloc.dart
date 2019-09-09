import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCChatBloc", enabled: true);

class IRCChatBloc extends Providable {
  final LoungeService _lounge;

  final Set<IRCNetwork> _networks = Set<IRCNetwork>();

  final BehaviorSubject<List<IRCNetwork>> _networksController =
      new BehaviorSubject<List<IRCNetwork>>(seedValue: []);

  Stream<List<IRCNetwork>> get networksStream => _networksController.stream;

  IRCNetworkChannel _activeChannel;
  final BehaviorSubject<IRCNetworkChannel> _activeChannelController =
      new BehaviorSubject<IRCNetworkChannel>();

  Stream<IRCNetworkChannel> get activeChannelStream =>
      _activeChannelController.stream;

  StreamSubscription<NetworksLoungeResponseBody> _networksSubscription;
  StreamSubscription<JoinLoungeResponseBody> _joinSubscription;

  IRCChatBloc(this._lounge) {
    _logger.i(() => "start creating");

    _networksSubscription = _lounge.networksStream.listen((event) {
      var newNetworks = Set<IRCNetwork>();

      for (var network in event.networks) {
        List<IRCNetworkChannel> newChannels = List();
        var newNetwork = IRCNetwork(network.name, network.uuid, newChannels);
        for (var loungeChannel in network.channels) {
          newChannels.add(IRCNetworkChannel(
              name: loungeChannel.name, remoteId: loungeChannel.id));
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
      changeActiveChanel(newChannel);
    });

    _logger.i(() => "stop creating");
  }

  List<IRCNetworkChannel> _calculateAvailableChannels() {
    var allChannels = List<IRCNetworkChannel>();
    _networks.forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  void _onNetworksListChanged() {
    _logger.i(() => "_onNetworksListChanged $_networks");
    _networksController.sink.add(UnmodifiableListView(_networks));

    if (_activeChannel == null) {
      var allChannels = _calculateAvailableChannels();
      if (allChannels.isNotEmpty) {
        changeActiveChanel(allChannels.first);
      }
    }
  }

  void dispose() {
    _networksController.close();

    _activeChannelController.close();
    _networksSubscription.cancel();

    _joinSubscription.cancel();
  }

  changeActiveChanel(IRCNetworkChannel newActiveChannel) async {
    if (_activeChannel == newActiveChannel) {
      return;
    }

    _logger.i(() =>"changeActiveChanel $changeActiveChanel");
    _activeChannel = newActiveChannel;
    _activeChannelController.sink.add(newActiveChannel);

    await _lounge.sendOpenRequest(newActiveChannel);
    await _lounge.sendNamesRequest(newActiveChannel);
  }
}
