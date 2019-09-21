import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';

var _logger =
    MyLogger(logTag: "NetworkChannelMessagesSaverBloc", enabled: true);

class NetworkChannelMessagesSaverBloc extends ChatNetworkChannelsBloc {
  final ChatDatabase db;

  Map<int, Disposable> channelsListeners = Map();

  NetworkChannelMessagesSaverBloc(ChatOutputBackendService backendService,
      ChatNetworksListBloc networksListBloc, this.db)
      : super(backendService, networksListBloc) {
    _logger.d(() => "Create NetworkChannelMessagesSaverBloc");
  }

  @override
  void onChannelJoined(
      Network network, NetworkChannel channel, NetworkChannelState state) {
    var channelListener =
        backendService.listenForMessages(network, channel, (newMessage) {
//      _logger.d(() => "onNewMessage $newMessage");
      var chatMessageType = ChatMessage.chatMessageType(newMessage);

      switch (chatMessageType) {
        case ChatMessageType.SPECIAL:
          db.specialMessagesDao
              .insertSpecialMessage(newMessage as SpecialMessage);
          break;
        case ChatMessageType.REGULAR:
          db.regularMessagesDao
              .insertRegularMessage(newMessage as RegularMessage);
          break;
      }
    });

    channelsListeners[channel.remoteId] = channelListener;

    addDisposable(disposable: channelListener);
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    db.specialMessagesDao.deleteChannelSpecialMessages(channel.remoteId);
    db.regularMessagesDao.deleteChannelRegularMessages(channel.remoteId);

    channelsListeners.remove(channel.remoteId).dispose();
  }
}
