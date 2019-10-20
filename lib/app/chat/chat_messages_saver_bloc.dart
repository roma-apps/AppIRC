import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_list_listener_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_preview_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_db.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_db.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/async/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

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

    channelWithState.initMessages?.forEach(_onNewMessage);

    var channelDisposable = CompositeDisposable([]);

    channelDisposable
        .add(backendService.listenForMessages(network, channel, (newMessage) {
      _onNewMessage(newMessage);
    }));

    channelDisposable.add(backendService
        .listenForMessagePreviews(network, channel, (previewForMessage) async {
      var oldMessageDB = await db.regularMessagesDao
          .findMessageWithRemoteId(previewForMessage.remoteMessageId);

      var oldMessage = regularMessageDBToChatMessage(oldMessageDB);

      updatePreview(oldMessage, previewForMessage);

      var newMessageDB = toRegularMessageDB(oldMessage);
      newMessageDB.localId = oldMessageDB.localId;
      db.regularMessagesDao.updateRegularMessage(newMessageDB);
    }));

    channelDisposable.add(backendService
        .listenForMessagePreviews(network, channel, (previewForMessage) async {
      var oldMessageDB = await db.regularMessagesDao
          .findMessageWithRemoteId(previewForMessage.remoteMessageId);

      var oldMessage = regularMessageDBToChatMessage(oldMessageDB);

      updatePreview(oldMessage, previewForMessage);

      var newMessageDB = toRegularMessageDB(oldMessage);
      newMessageDB.localId = oldMessageDB.localId;
      db.regularMessagesDao.updateRegularMessage(newMessageDB);
    }));

    channelDisposable.add(backendService.listenForMessagePreviewToggle(
        network, channel, (MessageTogglePreview togglePreview) async {
      var previewForMessage = PreviewForMessage(togglePreview.message
          .messageRemoteId, togglePreview.preview);

      var oldMessageDB = await db.regularMessagesDao
          .findMessageWithRemoteId(previewForMessage.remoteMessageId);

      var oldMessage = regularMessageDBToChatMessage(oldMessageDB);

      var foundOldMessage = oldMessage.previews.firstWhere((preview) {
        return preview.link == previewForMessage.messagePreview.link;
      }, orElse: () => null);

      foundOldMessage.shown = togglePreview.newShownValue;

      var newMessageDB = toRegularMessageDB(oldMessage);
      newMessageDB.localId = oldMessageDB.localId;
      db.regularMessagesDao.updateRegularMessage(newMessageDB);
    }));



    _channelsListeners[channel.remoteId] = channelDisposable;

    addDisposable(disposable: channelDisposable);
    addDisposable(subject: _realtimeMessagesController);
  }

  void _onNewMessage(ChatMessage newMessage) async {
    _logger.d(() => "onNewMessage $newMessage");
    var chatMessageType = newMessage.chatMessageType;

    int id;
    switch (chatMessageType) {
      case ChatMessageType.SPECIAL:
        var specialMessageDB = toSpecialMessageDB(newMessage);
        id = await db.specialMessagesDao.insertSpecialMessage(specialMessageDB);
        break;
      case ChatMessageType.REGULAR:
        var regularMessageDB = toRegularMessageDB(newMessage);
        id = await db.regularMessagesDao.insertRegularMessage(regularMessageDB);
        break;
    }

    newMessage.messageLocalId = id;
    _realtimeMessagesController.add(newMessage);
  }

  // ignore: close_sinks
  BehaviorSubject<ChatMessage> _realtimeMessagesController = BehaviorSubject();

  Disposable listenForMessages(Network network, NetworkChannel channel,
      NetworkChannelMessageListener listener) {
    return StreamSubscriptionDisposable(
        _realtimeMessagesController.stream.listen((newMessage) {
      if (newMessage.channelRemoteId == channel.remoteId) {
        listener(newMessage);
      }
    }));
  }

  @override
  void onChannelLeaved(Network network, NetworkChannel channel) {
    db.specialMessagesDao.deleteChannelSpecialMessages(channel.remoteId);
    db.regularMessagesDao.deleteChannelRegularMessages(channel.remoteId);

    _channelsListeners.remove(channel.remoteId).dispose();
  }
}

void updatePreview(
    RegularMessage oldMessage, PreviewForMessage previewForMessage) {
  if (oldMessage.previews == null) {
    oldMessage.previews = [];
  }

  oldMessage.previews
      .removeWhere((preview) => preview.type == MessagePreviewType.LOADING);
  oldMessage.previews.add(previewForMessage.messagePreview);
}
