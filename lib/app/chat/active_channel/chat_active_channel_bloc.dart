import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/push/chat_push_service.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';
import 'package:flutter_appirc/local_preferences/local_preference_bloc_impl.dart';
import 'package:flutter_appirc/local_preferences/local_preferences_service.dart';
import 'package:flutter_appirc/push/push_model.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

var _preferenceKey = "chat.activeChannel";
var _logger = Logger("chat_active_channel_bloc.dart");

class ChatActiveChannelBloc extends ChannelListListenerBloc {
  static ChatActiveChannelBloc of(
    BuildContext context, {
    bool listen = true,
  }) =>
      Provider.of<ChatActiveChannelBloc>(
        context,
        listen: listen,
      );

  final ChatBackendService backendService;
  final NetworkListBloc networksListBloc;
  final ChatInitBloc chatInitBloc;
  final ChatPushesService pushesService;
  IntPreferenceBloc _preferenceBloc;

  int _channelRemoteIdFromLaunchPushMessage;

  Channel get activeChannel => _activeChannelSubject.value;

  // ignore: close_sinks
  final BehaviorSubject<Channel> _activeChannelSubject = BehaviorSubject();

  Stream<Channel> get activeChannelStream => _activeChannelSubject.stream;

  Stream<bool> isChannelActiveStream(Channel channel) =>
      activeChannelStream.map(
        (activeChannel) => channel.remoteId == activeChannel?.remoteId,
      );

  bool isChannelActive(Channel channel) =>
      channel.remoteId == activeChannel?.remoteId;

  ChatActiveChannelBloc({
    @required this.backendService,
    @required this.chatInitBloc,
    @required this.networksListBloc,
    @required ILocalPreferencesService preferencesService,
    @required this.pushesService,
  }) : super(
          networksListBloc: networksListBloc,
        ) {
    _preferenceBloc = createActiveChannelPreferenceBloc(preferencesService);

    addDisposable(
      streamSubscription: pushesService.chatPushMessageStream.listen(
        (chatPushMessage) async {
          _logger.fine(() => "chatPushMessageStream $chatPushMessage");

          var channelRemoteId = chatPushMessage.data?.chanId;
          if (channelRemoteId != null) {
            if (chatPushMessage.type == PushMessageType.resume) {
              var channel = await findChannelWithRemoteID(channelRemoteId);

              await changeActiveChanel(channel);
            } else if (chatPushMessage.type == PushMessageType.launch) {
              _channelRemoteIdFromLaunchPushMessage = channelRemoteId;
            }
          } else {
            _logger.shout(() => "Error during handling $chatPushMessage");
          }
        },
      ),
    );

    _logger.finest(() => "start creating");

    addDisposable(
      streamSubscription: chatInitBloc.stateStream.listen(
        (state) {
          if (state == ChatInitState.finished &&
              networksListBloc.networks.isNotEmpty) {
            tryRestoreActiveChannel();
          }
        },
      ),
    );

    addDisposable(disposable: _preferenceBloc);

    addDisposable(subject: _activeChannelSubject);

    _logger.finest(() => "stop creating");
  }

  void tryRestoreActiveChannel() async {
    if (chatInitBloc.state != ChatInitState.finished) {
      return;
    }

    if (activeChannel != null) {
      return;
    }

    if (_channelRemoteIdFromLaunchPushMessage != null) {
      await _restoreFromLaunchPushMessage();
    } else if (backendService.chatInit.activeChannelRemoteId != null) {
      await _restoreFromChatInitMessage();
    } else {
      await _restoreFromLocalPreferences();
    }
  }

  Future _restoreFromLaunchPushMessage() async => await _restoreByRemoteID(
        _channelRemoteIdFromLaunchPushMessage,
      );

  Future _restoreFromChatInitMessage() async => await _restoreByRemoteID(
        backendService.chatInit.activeChannelRemoteId,
      );

  Future _restoreByRemoteID(int chatInitActiveChannelRemoteID) async {
    Channel newActiveChannel =
        await findChannelWithRemoteID(chatInitActiveChannelRemoteID);

    if (newActiveChannel == null) {
      _logger.warning(() => "fail to _restoreByRemoteID "
          "$chatInitActiveChannelRemoteID");
      // sometimes required channel already leaved
      // usually when we try to restore active channel by remote config
      var allChannels = await networksListBloc.allNetworksChannels;
      if (allChannels?.isNotEmpty == true) {
        newActiveChannel = allChannels.first;
      }
    }

    await changeActiveChanel(newActiveChannel);
  }

  Future<Channel> findChannelWithRemoteID(int remoteId) async {
    var allChannels = await networksListBloc.allNetworksChannels;
    var newActiveChannel = allChannels.firstWhere(
        (channel) => channel.remoteId == remoteId,
        orElse: () => null);
    return newActiveChannel;
  }

  Future _restoreFromLocalPreferences() async {
    var allChannels = await networksListBloc.allNetworksChannels;

    if (allChannels != null && allChannels.isNotEmpty) {
      var savedLocalId = _preferenceBloc.value ?? allChannels.first.localId;
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
          await changeActiveChanel(foundActiveChannel);
        }
      }
    }
  }

  Future<void> changeActiveChanel(Channel newActiveChannel) async {
    if (chatInitBloc.state != ChatInitState.finished) {
      return;
    }

    if (activeChannel == newActiveChannel) {
      return;
    }

    _logger.finest(() => "changeActiveChanel $newActiveChannel");
    await _preferenceBloc.setValue(newActiveChannel.localId);
    _activeChannelSubject.sink.add(newActiveChannel);

    Network network = networksListBloc.findNetworkWithChannel(newActiveChannel);
    await backendService.sendChannelOpenedEventToServer(
      network: network,
      channel: newActiveChannel,
    );
    await backendService.requestChannelUsers(
      network: network,
      channel: newActiveChannel,
    );
  }

  Future _onActiveChannelLeaved() async {
    var allChannels = await networksListBloc.allNetworksChannels;

    if (allChannels.isNotEmpty) {
      await changeActiveChanel(allChannels.first);
    }
  }

  IntPreferenceBloc createActiveChannelPreferenceBloc(
    ILocalPreferencesService preferencesService,
  ) =>
      IntPreferenceBloc(preferencesService, _preferenceKey);

  @override
  void onChannelJoined(Network network, ChannelWithState channelWithState) {
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
