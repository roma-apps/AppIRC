import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_db.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:rxdart/subjects.dart';

class ChannelStatesBloc extends ChannelListListenerBloc {
  final ChatDatabase _db;

  final Map<String, Map<int, BehaviorSubject<ChannelState>>> _statesMap = Map();

  List<ChannelState> get allStates {
    var states = <ChannelState>[];
    _statesMap.values.forEach((Map<int, BehaviorSubject<ChannelState>> entry) {
      states.addAll(entry.values.map((subject) => subject.value));
    });
    return List.unmodifiable(states);
  }

  // ignore: close_sinks
  final BehaviorSubject<ChannelState> _anyStateChangedSubject =
      BehaviorSubject();

  Stream<ChannelState> get anyStateChangedStream =>
      _anyStateChangedSubject.stream;

  final ChatActiveChannelBloc _activeChannelBloc;
  final ChatBackendService _backendService;

  ChannelStatesBloc(
    this._backendService,
    this._db,
    NetworkListBloc networksListBloc,
    this._activeChannelBloc,
  ) : super(networksListBloc) {
    addDisposable(subject: _anyStateChangedSubject);
    addDisposable(streamSubscription:
        _activeChannelBloc.activeChannelStream.listen((newActiveChannel) {
      Network networkForChannel =
          networksListBloc.findNetworkWithChannel(newActiveChannel);

      var state = getChannelState(networkForChannel, newActiveChannel);
      state.unreadCount = 0;
      _updateState(networkForChannel, newActiveChannel, state);
    }));
  }

  BehaviorSubject<ChannelState> _getStateSubjectForChannel(
      Network network, Channel channel) {
    var networkKey = _calculateNetworkKey(network);
    var channelKey = _calculateChannelKey(channel);

    return _statesMap[networkKey][channelKey];
  }

  void _updateState(Network network, Channel channel, ChannelState state) {
    if (_activeChannelBloc.activeChannel == channel) {
      state.unreadCount = 0;
    }

    // ignore: close_sinks
    var stateSubject = _getStateSubjectForChannel(network, channel);
    // sometimes subject already disposed and removed
    // for example new messages during exit
    stateSubject?.add(state);

    _onStateChanged(state);
  }

  void _onStateChanged(ChannelState state) {
    _anyStateChangedSubject.add(state);
  }

  String _calculateNetworkKey(Network network) => network.remoteId;

  int _calculateChannelKey(Channel channel) => channel.remoteId;

  BehaviorSubject<ChannelState> getChannelStateSubject(
          Network network, Channel channel) =>
      _statesMap[_calculateNetworkKey(network)][_calculateChannelKey(channel)];

  Stream<ChannelState> getChannelStateStream(
          Network network, Channel channel) =>
      getChannelStateSubject(network, channel).stream;

  ChannelState getChannelState(Network network, Channel channel) =>
      getChannelStateSubject(network, channel)?.value;

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    var network = networkWithState.network;
    var networkKey = _calculateNetworkKey(network);
    if (!_statesMap.containsKey(networkKey)) {
      _statesMap[networkKey] = Map<int, BehaviorSubject<ChannelState>>();
    }

    super.onNetworkJoined(networkWithState);
  }

  @override
  void onNetworkLeaved(Network network) {
    super.onNetworkLeaved(network);

    var networkKey = _calculateNetworkKey(network);

    _statesMap.remove(networkKey);
  }

  @override
  void onChannelJoined(Network network, ChannelWithState channelWithState) {
    var channel = channelWithState.channel;
    var networkKey = _calculateNetworkKey(network);
    var channelKey = _calculateChannelKey(channel);

    if (!_statesMap[networkKey].containsKey(channelKey)) {
      _statesMap[networkKey][channelKey] = BehaviorSubject<ChannelState>.seeded(
        ChannelState.empty,
      );
    }

    var state = channelWithState.state;
    _updateState(network, channel, state);
    addDisposable(
      disposable: _backendService.listenForChannelState(
        network,
        channel,
        () => _getStateSubjectForChannel(network, channel).value,
        () => calculateChannelMessagesCount(channel),
        (state) {
          _updateState(network, channel, state);
        },
      ),
    );
  }

  @override
  void onChannelLeaved(Network network, Channel channel) {
//    Future.delayed(Duration(microseconds:  1000), () {
    var stateSubject = _getStateSubjectForChannel(network, channel);
    var state = stateSubject.value;
    stateSubject.close();
    // ignore: close_sinks
    var networkKey = _calculateNetworkKey(network);
    var channelKey = _calculateChannelKey(channel);
    var networkMap = _statesMap[networkKey];
    networkMap.remove(channelKey);
    _onStateChanged(state);
//    });
  }

  Future<int> calculateChannelMessagesCount(Channel channel) async {
    var result = await _db.database
        .rawQuery(RegularMessageDao.createChannelMessagesCountQuery(channel));

    return RegularMessageDao.extractCountFromQueryResult(result);
  }
}
