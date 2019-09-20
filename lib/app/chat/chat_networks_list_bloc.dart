import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_preferences_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "ChatBloc", enabled: true);

typedef LocalIdGenerator = Future<int> Function();

class ChatNetworksListBloc extends Providable {
  final LocalIdGenerator nextChannelIdGenerator;
  final LocalIdGenerator nextNetworkIdGenerator;
  final ChatInputOutputBackendService backendService;

  final Map<Network, ChatNetworkChannelsListBloc> _networksChannelListBlocs =
      Map<Network, ChatNetworkChannelsListBloc>();

  ChatNetworkChannelsListBloc getChatNetworkChannelsListBloc(Network network) =>
      _networksChannelListBlocs[network];

  ChatNetworksListBloc(this.backendService,
      {@required this.nextNetworkIdGenerator,
      @required this.nextChannelIdGenerator}) {
    addDisposable(subject: _networksController);
    addDisposable(subject: _lastJoinedNetworkController);
    addDisposable(subject: _lastExitedNetworkController);


    addDisposable(
        disposable: backendService.listenForNetworkEnter((network) async {
          if (network.localId == null) {
            network.localId = await _nextNetworkLocalId;
          }
          for (var channel in network.channels) {
            if (channel.localId == null) {
              channel.localId = await _nextNetworkChannelLocalId;
            }
          }

          _networksChannelListBlocs[network] = ChatNetworkChannelsListBloc(
              backendService, network, nextChannelIdGenerator);

          var networks = _currentNetworks;

          Disposable listenForNetworkExit;
          listenForNetworkExit = backendService.listenForNetworkExit(network, () {
            var networks = _currentNetworks;

            _networksChannelListBlocs.remove(network).dispose();

            networks.remove(network);
            _lastExitedNetworkController.add(network);
            _onNetworksChanged(networks);
            listenForNetworkExit.dispose();
          });
          addDisposable(disposable: listenForNetworkExit);

          networks.add(network);
          _lastJoinedNetworkController.add(network);
          _onNetworksChanged(networks);
        }));

  }

  void _onNetworksChanged(List<Network> networks) {
    _networksController.add(networks);
  }

  Future<bool> isNetworkWithNameExist(String name) async {
    var found = networks.firstWhere((network) => network.name == name,
        orElse: () => null);

    return found != null;
  }

  Future<int> get _nextNetworkLocalId async => await nextNetworkIdGenerator();

  Future<int> get _nextNetworkChannelLocalId async =>
      await nextChannelIdGenerator();

  var _networksController = BehaviorSubject<List<Network>>(seedValue: []);

  // ignore: close_sinks
  var _lastJoinedNetworkController = BehaviorSubject<Network>();

  Stream<Network> get lastJoinedNetworkStream =>
      _lastJoinedNetworkController.stream;

  // ignore: close_sinks
  var _lastExitedNetworkController = BehaviorSubject<Network>();

  Stream<Network> get _lastExitedNetworkStream =>
      _lastExitedNetworkController.stream;

  Stream<UnmodifiableListView<Network>> get networksStream =>
      _networksController.stream
          .map((networks) => UnmodifiableListView(networks));

  UnmodifiableListView<Network> get networks =>
      UnmodifiableListView(_networksController.value);

  List<Network> get _currentNetworks => _networksController.value;

  Stream<int> get networksCountStream => networksStream.map((networks) {
        if (networks != null) {
          return 0;
        } else {
          return networks?.length;
        }
      });

  bool get isNetworksEmpty => networks.isEmpty;

  Stream<bool> get isNetworksEmptyStream => networksStream.map((networks) {
        if (networks != null) {
          return true;
        } else {
          return networks.isEmpty;
        }
      });

  Future<List<NetworkChannel>> get allNetworksChannels async {
    var allChannels = List<NetworkChannel>();
    networks.forEach((network) {
      allChannels.addAll(network.channels);
    });

    return allChannels;
  }

  Future<RequestResult<Network>> joinNetwork(IRCNetworkPreferences preferences,
          {bool waitForResult: false}) async =>
      await backendService.joinNetwork(preferences,
          waitForResult: waitForResult);

  Future<RequestResult<bool>> leaveNetwork(Network network,
          {bool waitForResult: false}) async =>
      await backendService.leaveNetwork(network, waitForResult: waitForResult);

  Network findNetworkWithChannel(NetworkChannel channel) =>
      networks.firstWhere((network) => network.channels.contains(channel));


}
