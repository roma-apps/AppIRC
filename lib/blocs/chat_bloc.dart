import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

const String _logTag = "ChatBloc";

class ChatBloc extends Providable {
  final LoungeService lounge;


  StreamSubscription<NetworksLoungeResponseBody> _networksSubscription;
  StreamSubscription<JoinLoungeResponseBody> _joinSubscription;

  ChatBloc(this.lounge) {

    logi(_logTag, "start creating");

    _networksSubscription = lounge.outNetworks.listen((event) {
      var newNetworks = Set<Network>();

      for (var network in event.networks) {
        List<Channel> newChannels = List();
        var newNetwork = Network(network.name, network.uuid, newChannels);
        for (var loungeChannel in network.channels) {
          newChannels.add(
              Channel(name: loungeChannel.name, remoteId: loungeChannel.id));
        }
        newNetworks.add(newNetwork);
      }

      _networks.addAll(newNetworks);

      _onNetworksListChanged();
    });

    _joinSubscription = lounge.outJoin.listen((event) {
      var networkForChannel =
          _networks.firstWhere((network) => network.remoteId == event.network);
      var newChannel = Channel(name: event.chan.name, remoteId: event.chan.id);
      networkForChannel.channels
          .add(newChannel);
      _onNetworksListChanged();
      changeActiveChanel(newChannel);

    });

    logi(_logTag, "stop creating");
  }


  List<Channel> _calculateAvailableChannels() {
    var allChannels = List<Channel>();
    _networks.forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  Set<Network> _networks = Set<Network>();

  newNetwork(IRCNetworkPreferences channelConnectionInfo) async =>
      await lounge.sendNewNetworkRequest(channelConnectionInfo);

  BehaviorSubject<List<Network>> _networkController =
      new BehaviorSubject<List<Network>>(seedValue: []);

  Stream<List<Network>> get outNetworks => _networkController.stream;



  Channel _activeChannel;
  BehaviorSubject<Channel> _activeChannelController =
      new BehaviorSubject<Channel>();

  Stream<Channel> get outActiveChannel => _activeChannelController.stream;

  void _onNetworksListChanged() {
    logi(_logTag, "_onNetworksListChanged $_networks");
    _networkController.sink.add(UnmodifiableListView(_networks));

    if (_activeChannel == null) {
      var allChannels = _calculateAvailableChannels();
      if (allChannels.length > 0) {
        changeActiveChanel(allChannels.elementAt(0));
      }
    }
  }

  void dispose() {
    _networkController.close();

    _activeChannelController.close();
    _networksSubscription.cancel();

    _joinSubscription.cancel();
  }

  void changeActiveChanel(Channel newActiveChannel) {
    if (_activeChannel == newActiveChannel) {
      return;
    }

    logi(_logTag, "changeActiveChanel $changeActiveChanel");
    _activeChannel = newActiveChannel;
    _activeChannelController.sink.add(newActiveChannel);

    lounge.sendOpenRequest(newActiveChannel);
    lounge.sendNamesRequest(newActiveChannel);
  }
}
