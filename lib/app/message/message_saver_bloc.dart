import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_listener_bloc.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_db.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_db.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/async_disposable.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "message_saver_bloc.dart", enabled: true);

class MessageSaverBloc
    extends ChannelListListenerBloc {
  final ChatBackendService _backendService;
  final ChatDatabase _db;

  final Map<int, Disposable> _channelsListeners = Map();

  MessageSaverBloc(
      this._backendService, NetworkListBloc networksListBloc, this._db)
      : super(networksListBloc) {
    _logger.d(() => "Create ChannelMessagesSaverBloc");
  }

  // ignore: close_sinks
  BehaviorSubject<ChatMessage> _realtimeMessagesSubject = BehaviorSubject();

  Disposable listenForMessages(Network network, Channel channel,
      ChannelMessageListener listener) {
    return StreamSubscriptionDisposable(
        _realtimeMessagesSubject.stream.listen((newMessage) {
          if (newMessage.channelRemoteId == channel.remoteId) {
            listener(newMessage);
          }
        }));
  }


  @override
  void onChannelJoined(
      Network network, ChannelWithState channelWithState) {
    Channel channel = channelWithState.channel;

    _logger.d(() => "listen for mesasges from channel $channel");

    channelWithState.initMessages?.forEach(_onNewMessage);

    var channelDisposable = CompositeDisposable([]);

    channelDisposable
        .add(_backendService.listenForMessages(network, channel, (newMessage) {
      _onNewMessage(newMessage);
    }));

    channelDisposable.add(_backendService
        .listenForMessagePreviews(network, channel, (previewForMessage) async {
      await _updatePreview(previewForMessage);
    }));


    channelDisposable.add(_backendService.listenForMessagePreviewToggle(
        network, channel, (ToggleMessagePreviewData togglePreview) async {
      await _togglePreview(togglePreview);
    }));

    _channelsListeners[channel.remoteId] = channelDisposable;

    addDisposable(disposable: channelDisposable);
    addDisposable(subject: _realtimeMessagesSubject);
  }

  Future _togglePreview(ToggleMessagePreviewData togglePreview) async {
      var previewForMessage = MessagePreviewForRemoteMessageId(
        togglePreview.message.messageRemoteId, togglePreview.preview);

    var oldMessageDB = await _db.regularMessagesDao
        .findMessageWithRemoteId(previewForMessage.remoteMessageId);

    var oldMessage = regularMessageDBToChatMessage(oldMessageDB);

    var foundOldMessage = oldMessage.previews.firstWhere((preview) {
      return preview.link == previewForMessage.messagePreview.link;
    }, orElse: () => null);

    foundOldMessage.shown = togglePreview.newShownValue;

    var newMessageDB = toRegularMessageDB(oldMessage);
    newMessageDB.localId = oldMessageDB.localId;
    _db.regularMessagesDao.updateRegularMessage(newMessageDB);
  }

  Future _updatePreview(MessagePreviewForRemoteMessageId previewForMessage) async {
    var oldMessageDB = await _db.regularMessagesDao
        .findMessageWithRemoteId(previewForMessage.remoteMessageId);

    var oldMessage = regularMessageDBToChatMessage(oldMessageDB);

    updatePreview(oldMessage, previewForMessage);

    var newMessageDB = toRegularMessageDB(oldMessage);
    newMessageDB.localId = oldMessageDB.localId;
    _db.regularMessagesDao.updateRegularMessage(newMessageDB);
  }

  void _onNewMessage(ChatMessage newMessage) async {
    _logger.d(() => "onNewMessage $newMessage");
    var chatMessageType = newMessage.chatMessageType;

    int id;
    switch (chatMessageType) {
      case ChatMessageType.special:
        var specialMessageDB = toSpecialMessageDB(newMessage);
        id = await _db.specialMessagesDao.insertSpecialMessage(specialMessageDB);
        break;
      case ChatMessageType.regular:
        var regularMessageDB = toRegularMessageDB(newMessage);
        id = await _db.regularMessagesDao.insertRegularMessage(regularMessageDB);
        break;
    }

    newMessage.messageLocalId = id;
    _realtimeMessagesSubject.add(newMessage);
  }


  @override
  void onChannelLeaved(Network network, Channel channel) {
    _db.specialMessagesDao.deleteChannelSpecialMessages(channel.remoteId);
    _db.regularMessagesDao.deleteChannelRegularMessages(channel.remoteId);

    _channelsListeners.remove(channel.remoteId).dispose();
  }
}

void updatePreview(
    RegularMessage oldMessage, MessagePreviewForRemoteMessageId previewForMessage) {
  if (oldMessage.previews == null) {
    oldMessage.previews = [];
  }

  oldMessage.previews
      .removeWhere((preview) => preview.type == MessagePreviewType.loading);
  oldMessage.previews.add(previewForMessage.messagePreview);
}
