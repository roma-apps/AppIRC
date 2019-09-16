import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/chat/chat_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = MyLogger(logTag: "IRCChatActiveChannelBloc", enabled: true);

class IRCChatActiveChannelBloc extends AsyncOperationBloc {
  final LoungeService lounge;

  final ChatBloc networksListBloc;
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

  void _onNetworksListChanged() async {
    if (_activeChannel == null) {
      var allChannels = await networksListBloc.allNetworksChannels;

      if (allChannels != null && allChannels.isNotEmpty) {
        var savedLocalId =
            await preferenceBloc.getValue(allChannels.first.localId);
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
        preferenceBloc.setValue(newActiveChannel.localId);
        _activeChannelController.sink.add(newActiveChannel);

        await lounge.sendOpenRequest(newActiveChannel);
        await lounge.sendNamesRequest(newActiveChannel);
      });
}

IntPreferencesBloc createActiveChannelPreferenceBloc(
        PreferencesService preferencesService) =>
    IntPreferencesBloc(preferencesService, "chat.activeChannel.localId");
