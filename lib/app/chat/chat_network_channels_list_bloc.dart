import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatNetworkChannelsListBloc extends Providable {
  final ChatOutputBackendService backendService;
  final Network network;
  final LocalIdGenerator nextChannelIdGenerator;


  Future<int> get _nextNetworkChannelLocalId async =>
      await nextChannelIdGenerator();

  ChatNetworkChannelsListBloc(
      this.backendService, this.network, this.nextChannelIdGenerator) {
    addDisposable(subject: _networksChannelsController);
    addDisposable(subject: _lastJoinedNetworkChannelController);
    addDisposable(subject: _lastExitedNetworkChannelController);

    var listenForNetworkChannelJoin =
        backendService.listenForNetworkChannelJoin(network, (channel) async {
      channel.localId = await _nextNetworkChannelLocalId;
      network.channels.add(channel);

      _onChannelsChanged(_currentNetworkChannels);

      _lastJoinedNetworkChannelController.add(channel);

      Disposable listenForNetworkChannelLeave;

      listenForNetworkChannelLeave = backendService
          .listenForNetworkChannelLeave(network, channel, () async {
        network.channels.remove(channel);
        _lastExitedNetworkChannelController.add(channel);
        _onChannelsChanged(_currentNetworkChannels);
        listenForNetworkChannelLeave.dispose();
      });
      addDisposable(disposable: listenForNetworkChannelLeave);
    });

    addDisposable(disposable: listenForNetworkChannelJoin);
  }

  void _onChannelsChanged(List<NetworkChannel> networkChannels) {
    _networksChannelsController.add(networkChannels);
  }

  List<NetworkChannel> get _currentNetworkChannels =>
      _networksChannelsController.value;

  // ignore: close_sinks
  var _networksChannelsController =
      BehaviorSubject<List<NetworkChannel>>(seedValue: []);

  // ignore: close_sinks
  var _lastJoinedNetworkChannelController = BehaviorSubject<NetworkChannel>();

  Stream<NetworkChannel> get lastJoinedNetworkChannelStream =>
      _lastJoinedNetworkChannelController.stream;

  // ignore: close_sinks
  var _lastExitedNetworkChannelController = BehaviorSubject<NetworkChannel>();

  Stream<NetworkChannel> get lastExitedNetworkChannelStream =>
      _lastExitedNetworkChannelController.stream;

}
