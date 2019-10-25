import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/push_notifications/chat_pushes_service.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = MyLogger(logTag: "ChatActiveChannelBloc", enabled: true);

class ChatActiveChannelBloc extends ChatNetworkChannelsListListenerBloc {
  final ChatInputBackendService _backendService;
  final ChatNetworksListBloc _networksListBloc;
  final ChatInitBloc _chatInitBloc;
  final ChatPushesService pushesService;
  IntPreferencesBloc _preferenceBloc;

  int _channelRemoteIdFromLaunchPushMessage;

  NetworkChannel get activeChannel => _activeChannelController.value;

  // ignore: close_sinks
  final BehaviorSubject<NetworkChannel> _activeChannelController =
      new BehaviorSubject();

  Stream<NetworkChannel> get activeChannelStream =>
      _activeChannelController.stream;

  ChatActiveChannelBloc(
      this._backendService,
      this._chatInitBloc,
      this._networksListBloc,
      PreferencesService preferencesService,
      this.pushesService)
      : super(_networksListBloc) {
    _preferenceBloc = createActiveChannelPreferenceBloc(preferencesService);

    addDisposable(streamSubscription:
        pushesService.chatPushMessageStream.listen((chatPushMessage) async {
      _logger.d(() => "chatPushMessageStream $chatPushMessage");

      var chanIdString = chatPushMessage.data?.chanId;
      if (chanIdString != null) {
        var channelRemoteId = int.parse(chanIdString);
        if (chatPushMessage.type == PushMessageType.RESUME) {
          var channel = await findChannelWithRemoteID(channelRemoteId);

          changeActiveChanel(channel);
        } else if (chatPushMessage.type == PushMessageType.LAUNCH) {
          _channelRemoteIdFromLaunchPushMessage = channelRemoteId;
        }
      } else {
        _logger.e(() => "Error during handling $chatPushMessage");
      }
    }));

    _logger.i(() => "start creating");

    addDisposable(streamSubscription: _chatInitBloc.stateStream.listen((state) {
      if (state == ChatInitState.FINISHED &&
          _networksListBloc.networks.isNotEmpty) {
        tryRestoreActiveChannel();
      }
    }));

    addDisposable(disposable: _preferenceBloc);

    addDisposable(subject: _activeChannelController);

    _logger.i(() => "stop creating");
  }

  void tryRestoreActiveChannel() async {
    if (_chatInitBloc.state != ChatInitState.FINISHED) {
      return;
    }

    if (activeChannel != null) {
      return;
    }

    if (_channelRemoteIdFromLaunchPushMessage != null) {
      _restoreFromLaunchPushMessage();
    } else if (_backendService.chatInit.activeChannelRemoteId != null) {
      await _restoreFromChatInitMessage();
    } else {
      await _restoreFromLocalPreferences();
    }
  }

  Future _restoreFromLaunchPushMessage() async =>
      await _restoreByRemoteID(_channelRemoteIdFromLaunchPushMessage);

  Future _restoreFromChatInitMessage() async =>
      await _restoreByRemoteID(_backendService.chatInit.activeChannelRemoteId);

  Future _restoreByRemoteID(int chatInitActiveChannelRemoteID) async {
    NetworkChannel newActiveChannel =
        await findChannelWithRemoteID(chatInitActiveChannelRemoteID);

    if (newActiveChannel == null) {
      _logger.w(() => "fail to _restoreByRemoteID "
          "$chatInitActiveChannelRemoteID");
      // sometimes required channel already leaved
      // usually when we try to restore active channel by remote config
      var allChannels = await _networksListBloc.allNetworksChannels;
      if (allChannels?.isNotEmpty == true) {
        newActiveChannel = allChannels.first;
      }
    }

    changeActiveChanel(newActiveChannel);
  }

  Future<NetworkChannel> findChannelWithRemoteID(int remoteId) async {
    var allChannels = await _networksListBloc.allNetworksChannels;
    var newActiveChannel = allChannels.firstWhere(
        (channel) => channel.remoteId == remoteId,
        orElse: () => null);
    return newActiveChannel;
  }

  Future _restoreFromLocalPreferences() async {
    var allChannels = await _networksListBloc.allNetworksChannels;

    if (allChannels != null && allChannels.isNotEmpty) {
      var savedLocalId =
          _preferenceBloc.getValue(defaultValue: allChannels.first.localId);
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

  changeActiveChanel(NetworkChannel newActiveChannel) async {
    if (_chatInitBloc.state != ChatInitState.FINISHED) {
      return;
    }

    if (activeChannel == newActiveChannel) {
      return;
    }

    _logger.i(() => "changeActiveChanel $newActiveChannel");
    _preferenceBloc.setValue(newActiveChannel.localId);
    _activeChannelController.sink.add(newActiveChannel);

    Network network =
        _networksListBloc.findNetworkWithChannel(newActiveChannel);
    _backendService.onOpenNetworkChannel(network, newActiveChannel);
    _backendService.requestNetworkChannelUsers(network, newActiveChannel);
  }

  _onActiveChannelLeaved() async {
    var allChannels = await _networksListBloc.allNetworksChannels;

    if (allChannels.length > 0) {
      changeActiveChanel(allChannels.first);
    }
  }

  IntPreferencesBloc createActiveChannelPreferenceBloc(
          PreferencesService preferencesService) =>
      IntPreferencesBloc(preferencesService, _preferenceKey);

  @override
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState) {
    var channel = channelWithState.channel;
    changeActiveChanel(channel);
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    if (activeChannel == channel) {
      _onActiveChannelLeaved();
    }
  }

  @override
  void onNetworkJoined(NetworkWithState networkWithState) {
    if (activeChannel == null) {
      tryRestoreActiveChannel();
    } else {
      changeActiveChanel(networkWithState.network.lobbyChannel);
    }

    super.onNetworkJoined(networkWithState);
  }
}
