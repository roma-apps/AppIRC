import 'dart:async';

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
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:rxdart/subjects.dart';

var _logger = MyLogger(logTag: "message_saver_bloc.dart", enabled: true);

class MessageManagerBloc extends ChannelListListenerBloc {
  final ChatBackendService _backendService;
  final ChatDatabase _db;

  final Map<int, Disposable> _channelsListeners = Map();
  final Map<int, List<ChannelMessageListener>> _channelsMessagesListeners =
      Map();

  // ignore: close_sinks
  BehaviorSubject<ChatMessage> _messageUpdateSubject = BehaviorSubject();

  Stream<ChatMessage> get messageUpdateStream => _messageUpdateSubject.stream;

  MessageManagerBloc(
      this._backendService, NetworkListBloc networksListBloc, this._db)
      : super(networksListBloc) {
    _logger.d(() => "Create ChannelMessagesSaverBloc");

    addDisposable(subject: _messageUpdateSubject);
  }

  Disposable listenForMessages(
      Network network, Channel channel, ChannelMessageListener listener) {
    var key = channel.remoteId;
    if (!_channelsMessagesListeners.containsKey(key)) {
      _channelsMessagesListeners[key] = List();
    }

    _channelsMessagesListeners[key].add(listener);

    return CustomDisposable(() {
      _channelsMessagesListeners[key].remove(listener);
    });
  }

  @override
  void onChannelJoined(Network network, ChannelWithState channelWithState) {
    Channel channel = channelWithState.channel;

    _logger.d(() => "listen for mesasges from channel $channel");

    _logger.d(() => "onChannelJoined _onNewMessages "
        "${channelWithState.initMessages.length}");
    _onNewMessages(MessagesForChannel.name(
        isNeedCheckAdditionalLoadMore: true,
        channel: channel,
        messages: channelWithState.initMessages,
        isNeedCheckAlreadyExistInLocalStorage: true));

    var channelDisposable = CompositeDisposable([]);

    channelDisposable.add(_backendService.listenForMessages(network, channel,
        (messagesForChannel) {
      _logger.d(() => "listenForMessages "
          "${messagesForChannel.messages.length}");
      _onNewMessages(messagesForChannel);
    }));

    channelDisposable.add(_backendService
        .listenForMessagePreviews(network, channel, (previewForMessage) async {
      var newMessage = await _updatePreview(channel, previewForMessage);

      _messageUpdateSubject.add(newMessage);
    }));

    channelDisposable.add(_backendService.listenForMessagePreviewToggle(
        network, channel, (ToggleMessagePreviewData togglePreview) async {
      var newMessage = await _togglePreview(channel, togglePreview);

      _messageUpdateSubject.add(newMessage);
    }));

    _channelsListeners[channel.remoteId] = channelDisposable;

    addDisposable(disposable: channelDisposable);
//    addDisposable(subject: _realtimeMessagesSubject);
  }

  Future<ChatMessage> _togglePreview(
      Channel channel, ToggleMessagePreviewData togglePreview) async {
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

  Future<ChatMessage> _updatePreview(Channel channel,
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

    List<ChatMessage> newMessages = messagesForChannel.messages;

    if (messagesForChannel.isNeedCheckAlreadyExistInLocalStorage) {
      List<int> alreadyExistRemoteIds = [];
      for (var message in messagesForChannel.messages) {
        if (message.isRegular) {
          var regularMessage = message as RegularMessage;
          var remoteId = regularMessage.messageRemoteId;
          var localMessage = await _db.regularMessagesDao
              .findMessageLocalIdWithRemoteId(remoteId);

          if (localMessage?.localId != null) {
            alreadyExistRemoteIds.add(remoteId);
          }
        }
      }

      if (alreadyExistRemoteIds.isNotEmpty) {
        newMessages.removeWhere((message) {
          if (message is RegularMessage) {
            return alreadyExistRemoteIds.contains(message.messageRemoteId);
          } else {
            return false;
          }
        });
      }
    }
    await _insertMessages(newMessages);

    // remove messages which already exist in local storage
//    messagesForChannel.messages =
//        newMessages.where((message) => message.messageLocalId == null).toList();

    var key = messagesForChannel.channel.remoteId;
    if (_channelsMessagesListeners.containsKey(key)) {
      _channelsMessagesListeners[key]
          .forEach((ChannelMessageListener listener) {
        listener(messagesForChannel);
      });
    }

//    _realtimeMessagesSubject.add(messagesForChannel);

    // don't await
    _extractLinks(messagesForChannel);
  }

  Future _insertMessages(List<ChatMessage> newMessages) async {
    await _insertRegularMessages(newMessages);
    await _insertSpecialMessages(newMessages);
  }

  Future _insertRegularMessages(List<ChatMessage> newMessages) async {
    List<RegularMessage> regularMessages = newMessages
        .where((message) => message.chatMessageType == ChatMessageType.regular)
        .map((message) => message as RegularMessage)
        .toList();

    if (regularMessages.isNotEmpty) {
      await _db.regularMessagesDao.upsertRegularMessages(regularMessages);
    }
  }

  Future _insertSpecialMessages(List<ChatMessage> newMessages) async {
    List<SpecialMessage> specialMessages = newMessages
        .where((message) => message.chatMessageType == ChatMessageType.special)
        .map((message) => message as SpecialMessage)
        .where((message) => message.specialType == SpecialMessageType.whoIs)
        .toList();

    if (specialMessages.isNotEmpty) {
      await _db.specialMessagesDao.upsertSpecialMessages(specialMessages);
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

    var regularMessagesToUpdate = <RegularMessageDB>[];
    var specialMessagesToUpdate = <SpecialMessageDB>[];
    for (int i = 0; i < messages.length; i++) {
      var message = messages[i];
      message.linksInText = linksList[i];

      if (message.linksInText.isNotEmpty) {
        switch (message.chatMessageType) {
          case ChatMessageType.regular:
            regularMessagesToUpdate.add(toRegularMessageDB(message));
            break;

          case ChatMessageType.special:
            specialMessagesToUpdate.add(toSpecialMessageDB(message));
            break;
        }

        _messageUpdateSubject.add(message);
      }
    }

    _db.regularMessagesDao.updateRegularMessages(regularMessagesToUpdate);
    _db.specialMessagesDao.updateSpecialMessages(specialMessagesToUpdate);
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
