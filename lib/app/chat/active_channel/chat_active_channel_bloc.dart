import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/push_notifications/chat_push_notifications.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_bloc.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/pushes/push_model.dart';
import 'package:rxdart/rxdart.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = MyLogger(logTag: "chat_active_channel_bloc.dart", enabled: true);

class ChatActiveChannelBloc extends ChannelListListenerBloc {
  final ChatBackendService _backendService;
  final NetworkListBloc _networksListBloc;
  final ChatInitBloc _chatInitBloc;
  final ChatPushesService pushesService;
  IntPreferencesBloc _preferenceBloc;

  int _channelRemoteIdFromLaunchPushMessage;

  Channel get activeChannel => _activeChannelSubject.value;

  // ignore: close_sinks
  final BehaviorSubject<Channel> _activeChannelSubject =
      new BehaviorSubject();

  Stream<Channel> get activeChannelStream =>
      _activeChannelSubject.stream;

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
        if (chatPushMessage.type == PushMessageType.resume) {
          var channel = await findChannelWithRemoteID(channelRemoteId);

          changeActiveChanel(channel);
        } else if (chatPushMessage.type == PushMessageType.launch) {
          _channelRemoteIdFromLaunchPushMessage = channelRemoteId;
        }
      } else {
        _logger.e(() => "Error during handling $chatPushMessage");
      }
    }));

    _logger.i(() => "start creating");

    addDisposable(streamSubscription: _chatInitBloc.stateStream.listen((state) {
      if (state == ChatInitState.finished &&
          _networksListBloc.networks.isNotEmpty) {
        tryRestoreActiveChannel();
      }
    }));

    addDisposable(disposable: _preferenceBloc);

    addDisposable(subject: _activeChannelSubject);

    _logger.i(() => "stop creating");
  }

  void tryRestoreActiveChannel() async {
    if (_chatInitBloc.state != ChatInitState.finished) {
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
    Channel newActiveChannel =
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

  Future<Channel> findChannelWithRemoteID(int remoteId) async {
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

  changeActiveChanel(Channel newActiveChannel) async {
    if (_chatInitBloc.state != ChatInitState.finished) {
      return;
    }

    if (activeChannel == newActiveChannel) {
      return;
    }

    _logger.i(() => "changeActiveChanel $newActiveChannel");
    _preferenceBloc.setValue(newActiveChannel.localId);
    _activeChannelSubject.sink.add(newActiveChannel);

    Network network =
        _networksListBloc.findNetworkWithChannel(newActiveChannel);
    _backendService.sendChannelOpenedEventToServer(network, newActiveChannel);
    _backendService.requestChannelUsers(network, newActiveChannel);
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
      Network network, ChannelWithState channelWithState) {
    var channel = channelWithState.channel;
    changeActiveChanel(channel);
  }

  @override
  void onChannelLeaved(Network network, Channel channel) {
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
