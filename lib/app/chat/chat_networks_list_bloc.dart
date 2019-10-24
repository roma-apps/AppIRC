import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

typedef LocalIdGenerator = int Function();

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


    addDisposable(disposable:
        backendService.listenForNetworkJoin((networkWithState) async {
       onNetworkJoined(networkWithState);
    }));
  }

   onNetworkJoined(NetworkWithState networkWithState) async {
         var network = networkWithState.network;

    if (network.localId == null) {
      network.localId = await _nextNetworkLocalId;
    }
    for (var channel in network.channels) {
      if (channel.localId == null) {
        channel.localId = await _nextNetworkChannelLocalId;
      }
    }

    _networksChannelListBlocs[network] = ChatNetworkChannelsListBloc(
        backendService,
        network,
        networkWithState.channelsWithState,
        nextChannelIdGenerator);



    Disposable listenForNetworkExit;
    listenForNetworkExit = backendService.listenForNetworkLeave(network, () {


      _networksChannelListBlocs.remove(network).dispose();

      _networks.remove(network);

      leaveListeners[network].forEach((listener) => listener());

      _onNetworksChanged(_networks);
      listenForNetworkExit.dispose();
    });
    addDisposable(disposable: listenForNetworkExit);

    _networks.add(network);

    joinListeners.forEach((listener) => listener(networkWithState));

    _onNetworksChanged(_networks);
  }

  void _onNetworksChanged(List<Network> networks) {
    _networksController.add(networks);
  }

  Future<bool> isNetworkWithNameExist(String name) async {
    var found = networks.firstWhere((network) => network.name == name,
        orElse: () => null);

    return found != null;
  }

  Future<int> get _nextNetworkLocalId async => nextNetworkIdGenerator();

  Future<int> get _nextNetworkChannelLocalId async => nextChannelIdGenerator();

  var _networksController = BehaviorSubject<List<Network>>(seedValue: []);

  final List<NetworkListener> joinListeners = [];
  final Map<Network, List<VoidCallback>> leaveListeners = Map();

  Disposable listenForNetworkJoin(NetworkListener listener) {

    joinListeners.add(listener);
    return CustomDisposable(() {
      joinListeners.remove(listener);
    });
  }

  Disposable listenForNetworkLeave(Network network, VoidCallback listener) {


    if(!leaveListeners.containsKey(network)) {
      leaveListeners[network] = [];
    }
    leaveListeners[network].add(listener);
    return CustomDisposable(() {
      leaveListeners[network].remove(listener);
    });
  }


  Stream<UnmodifiableListView<Network>> get networksStream =>
      _networksController.stream
          .map((networks) => UnmodifiableListView(networks));

  UnmodifiableListView<Network> get networks =>
      UnmodifiableListView(_networks);

  List<Network> get _networks => _networksController.value;


  Stream<int> get networksCountStream => networksStream.map((networks) {
        if (networks != null) {
          return 0;
        } else {
          return networks?.length;
        }
      });

  bool get isNetworksEmpty => _networks.isEmpty;

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

  Future<RequestResult<NetworkWithState>> joinNetwork(
          ChatNetworkPreferences preferences,
          {bool waitForResult: false}) async =>
      await backendService.joinNetwork(preferences,
          waitForResult: waitForResult);



  Future<RequestResult<bool>> leaveNetwork(Network network,
          {bool waitForResult: false}) async =>
      await backendService.leaveNetwork(network, waitForResult: waitForResult);

  Network findNetworkWithChannel(NetworkChannel channel) =>
      networks.firstWhere((network) => network.channels.contains(channel));
}
