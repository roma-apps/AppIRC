import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/blocs/preferences_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/service/preferences_service.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = MyLogger(logTag: "IRCChatBloc", enabled: true);

class IRCChatActiveChannelBloc extends AsyncOperationBloc {
  final LoungeService lounge;

  final IRCNetworksListBloc networksListBloc;
  final IntPreferencesBloc preferenceBloc;

  IRCNetworkChannel _activeChannel;
  final BehaviorSubject<IRCNetworkChannel> _activeChannelController =
      new BehaviorSubject<IRCNetworkChannel>();

  StreamSubscription<List<IRCNetwork>> _networksSubscription;

  Stream<IRCNetworkChannel> get activeChannelStream =>
      _activeChannelController.stream;

  IRCChatActiveChannelBloc(
      {@required this.lounge,
      @required this.preferenceBloc,
      @required this.networksListBloc}) {
    _logger.i(() => "start creating");

    _networksSubscription = networksListBloc.newNetworksStream
        .listen((newNetworks) async => _onNetworksListChanged());

    _logger.i(() => "stop creating");
  }

  void _onNetworksListChanged() {
    if (_activeChannel == null) {
      var allChannels = networksListBloc.allNetworksChannels;

      if (allChannels != null && allChannels.isNotEmpty) {
        var savedLocalId = preferenceBloc
            .getPreferenceOrValue(() => allChannels.first.localId);
        if (savedLocalId != null) {
          var filtered =
              allChannels.where((channel) => channel.localId == savedLocalId);

          var foundActiveChannel;
          if (filtered.isNotEmpty) {
            foundActiveChannel = filtered.first;
          }

          if (foundActiveChannel == null && allChannels.isNotEmpty) {
            foundActiveChannel = allChannels.first;
          }

          if (foundActiveChannel != null) {
            changeActiveChanel(foundActiveChannel);
          }
        }
      }
    }
  }

  void dispose() {
    super.dispose();
    _activeChannelController.close();
    _networksSubscription.cancel();
  }

  changeActiveChanel(IRCNetworkChannel newActiveChannel) async =>
      doAsyncOperation(() async {
        if (_activeChannel == newActiveChannel) {
          return;
        }

        _logger.i(() => "changeActiveChanel $changeActiveChanel");
        _activeChannel = newActiveChannel;
        preferenceBloc.setNewPreferenceValue(newActiveChannel.localId);
        _activeChannelController.sink.add(newActiveChannel);

        await lounge.sendOpenRequest(newActiveChannel);
        await lounge.sendNamesRequest(newActiveChannel);
      });
}

IntPreferencesBloc createActiveChannelPreferenceBloc(
        PreferencesService preferencesService) =>
    IntPreferencesBloc(preferencesService, "chat.activeChannel.localId", null);
