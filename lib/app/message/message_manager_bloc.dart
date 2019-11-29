import 'package:flutter/foundation.dart';
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

class MessageManagerBloc extends ChannelListListenerBloc {
  final ChatBackendService _backendService;
  final ChatDatabase _db;

  final Map<int, Disposable> _channelsListeners = Map();

  // ignore: close_sinks
  BehaviorSubject<ChatMessage> _messageUpdateSubject = BehaviorSubject();

  Stream<ChatMessage> get messageUpdateStream => _messageUpdateSubject.stream;

  // ignore: close_sinks
  BehaviorSubject<MessagesForChannel> _realtimeMessagesSubject =
      BehaviorSubject();

  MessageManagerBloc(
      this._backendService, NetworkListBloc networksListBloc, this._db)
      : super(networksListBloc) {
    _logger.d(() => "Create ChannelMessagesSaverBloc");

    addDisposable(subject: _realtimeMessagesSubject);
    addDisposable(subject: _messageUpdateSubject);
  }

  Disposable listenForMessages(
      Network network, Channel channel, ChannelMessageListener listener) {
    return StreamSubscriptionDisposable(
        _realtimeMessagesSubject.stream.listen((messagesForChannel) {
      if (messagesForChannel.channel.remoteId == channel.remoteId) {
        listener(messagesForChannel);
      }
    }));
  }

  @override
  void onChannelJoined(Network network, ChannelWithState channelWithState) {
    Channel channel = channelWithState.channel;

    _logger.d(() => "listen for mesasges from channel $channel");

    _logger.d(() => "onChannelJoined _onNewMessages "
        "${channelWithState.initMessages.length}");
    _onNewMessages(MessagesForChannel.name(
        channel: channel, messages: channelWithState.initMessages));

    var channelDisposable = CompositeDisposable([]);

    channelDisposable.add(_backendService.listenForMessages(network, channel,
        (messagesForChannel) {
      _logger.d(() => "onChannelJoined listenForMessages "
          "${messagesForChannel.messages.length}");
      _onNewMessages(messagesForChannel);
    }));

    channelDisposable.add(_backendService
        .listenForMessagePreviews(network, channel, (previewForMessage) async {
      var newMessage = await _updatePreview(previewForMessage);

      _messageUpdateSubject.add(newMessage);
    }));

    channelDisposable.add(_backendService.listenForMessagePreviewToggle(
        network, channel, (ToggleMessagePreviewData togglePreview) async {
      var newMessage = await _togglePreview(togglePreview);

      _messageUpdateSubject.add(newMessage);
    }));

    _channelsListeners[channel.remoteId] = channelDisposable;

    addDisposable(disposable: channelDisposable);
    addDisposable(subject: _realtimeMessagesSubject);
  }

  Future<ChatMessage> _togglePreview(
      ToggleMessagePreviewData togglePreview) async {
    var previewForMessage = MessagePreviewForRemoteMessageId(
        togglePreview.message.messageRemoteId, togglePreview.preview);

    var oldMessageDB = await _db.regularMessagesDao
        .findMessageWithRemoteId(previewForMessage.remoteMessageId);

    var message = regularMessageDBToChatMessage(oldMessageDB);

    var foundOldMessage = message.previews.firstWhere((preview) {
      return preview.link == previewForMessage.messagePreview.link;
    }, orElse: () => null);

    foundOldMessage.shown = togglePreview.newShownValue;

    var newMessageDB = toRegularMessageDB(message);
    newMessageDB.localId = oldMessageDB.localId;
    _db.regularMessagesDao.updateRegularMessage(newMessageDB);

    return message;
  }

  Future<ChatMessage> _updatePreview(
      MessagePreviewForRemoteMessageId previewForMessage) async {
    var oldMessageDB = await _db.regularMessagesDao
        .findMessageWithRemoteId(previewForMessage.remoteMessageId);

    var message = regularMessageDBToChatMessage(oldMessageDB);

    updatePreview(message, previewForMessage);

    var newMessageDB = toRegularMessageDB(message);
    newMessageDB.localId = oldMessageDB.localId;
    _db.regularMessagesDao.updateRegularMessage(newMessageDB);

    return message;
  }

  void _onNewMessages(MessagesForChannel messagesForChannel) async {
    _logger.d(() => "_onNewMessages $messagesForChannel");

    var newMessages = messagesForChannel.messages;

    for (var newMessage in newMessages) {
      int id = await _insertMessage(newMessage);

      newMessage.messageLocalId = id;
    }

    _realtimeMessagesSubject.add(messagesForChannel);

    // don't await
    _extractLinks(messagesForChannel);
  }

  Future<int> _insertMessage(ChatMessage newMessage) async {
    int id;
    var chatMessageType = newMessage.chatMessageType;

    switch (chatMessageType) {
      case ChatMessageType.regular:
        var regularMessage = newMessage as RegularMessage;

        var foundMessage = await _db.regularMessagesDao
            .findMessageWithRemoteId(regularMessage.messageRemoteId);

        if (foundMessage != null) {
          // nothing
          id = foundMessage.localId;
        } else {
          var regularMessageDB = toRegularMessageDB(newMessage);
          id = await _db.regularMessagesDao
              .insertRegularMessage(regularMessageDB);
        }
        break;
      case ChatMessageType.special:
        var specialMessageDB = toSpecialMessageDB(newMessage);
        id =
            await _db.specialMessagesDao.insertSpecialMessage(specialMessageDB);
        break;
    }

    return id;
  }

  Future _updateMessage(ChatMessage newMessage) async {
    var chatMessageType = newMessage.chatMessageType;

    switch (chatMessageType) {
      case ChatMessageType.special:
        var specialMessageDB = toSpecialMessageDB(newMessage);
        specialMessageDB.localId = newMessage.messageLocalId;
        await _db.specialMessagesDao.updateRegularMessage(specialMessageDB);
        break;
      case ChatMessageType.regular:
        var regularMessageDB = toRegularMessageDB(newMessage);
        regularMessageDB.localId = newMessage.messageLocalId;
        await _db.regularMessagesDao.updateRegularMessage(regularMessageDB);
        break;
    }
  }

  @override
  void onChannelLeaved(Network network, Channel channel) {
    _db.specialMessagesDao.deleteChannelSpecialMessages(channel.remoteId);
    _db.regularMessagesDao.deleteChannelRegularMessages(channel.remoteId);

    _channelsListeners.remove(channel.remoteId).dispose();
  }

  Future _extractLinks(MessagesForChannel messagesForChannel) async {
    var messages = messagesForChannel.messages;
    var linksList = await compute(extractLinks, messages);

    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      message.linksInText = linksList[i];

      if (message.linksInText.isNotEmpty) {
        _updateMessage(message);
        _messageUpdateSubject.add(message);
      }
    }
  }

  Stream<ChatMessage> getMessageUpdateStream(ChatMessage message) =>
      messageUpdateStream.where((updatedMessage) => message == updatedMessage);

  Future clearAllMessages() async {
    await _db.regularMessagesDao.deleteAllRegularMessages();
    await _db.specialMessagesDao.deleteAllSpecialMessages();
  }
}

Future<List<List<String>>> extractLinks(List<ChatMessage> messages) async {
  Iterable<Future<List<String>>> mappedList =
      messages.map((i) => i.extractLinks());
  print(mappedList); // you print an Iterable of Future

  // to get the list of int you have to do the following
  Future<List<List<String>>> futureList = Future.wait(mappedList);
  List<List<String>> result = await futureList;

  return result;
}

void updatePreview(RegularMessage oldMessage,
    MessagePreviewForRemoteMessageId previewForMessage) {
  if (oldMessage.previews == null) {
    oldMessage.previews = [];
  }

  oldMessage.previews.clear();
  oldMessage.previews.add(previewForMessage.messagePreview);
}
