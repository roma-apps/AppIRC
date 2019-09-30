import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_db.dart';
import 'package:flutter_appirc/app/message/messages_special_db.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';

var _logger =
    MyLogger(logTag: "NetworkChannelMessagesSaverBloc", enabled: true);

class NetworkChannelMessagesSaverBloc
    extends ChatNetworkChannelsListListenerBloc {
  final ChatOutputBackendService backendService;
  final ChatDatabase db;

  Map<int, Disposable> _channelsListeners = Map();

  NetworkChannelMessagesSaverBloc(
      this.backendService, ChatNetworksListBloc networksListBloc, this.db)
      : super(networksListBloc) {
    _logger.d(() => "Create NetworkChannelMessagesSaverBloc");
  }

  @override
  void onChannelJoined(
      Network network, NetworkChannelWithState channelWithState) {
    NetworkChannel channel = channelWithState.channel;

    _logger.d(() => "listen for mesasges from channel $channel");

    var channelListener =
        backendService.listenForMessages(network, channel, (newMessage) {
      _logger.d(() => "onNewMessage $newMessage");
      var chatMessageType = newMessage.chatMessageType;

      switch (chatMessageType) {
        case ChatMessageType.SPECIAL:
          db.specialMessagesDao
              .insertSpecialMessage(toSpecialMessageDB(newMessage));
          break;
        case ChatMessageType.REGULAR:
          db.regularMessagesDao
              .insertRegularMessage(toRegularMessageDB(newMessage));
          break;
      }
    });

    _channelsListeners[channel.remoteId] = channelListener;

    addDisposable(disposable: channelListener);
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    db.specialMessagesDao.deleteChannelSpecialMessages(channel.remoteId);
    db.regularMessagesDao.deleteChannelRegularMessages(channel.remoteId);

    _channelsListeners.remove(channel.remoteId).dispose();
  }
}
