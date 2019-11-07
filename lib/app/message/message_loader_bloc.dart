import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/message_saver_bloc.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_db.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_db.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "message_loader_bloc.dart", enabled: true);

class MessageLoaderBloc extends Providable {
  final ChatBackendService _backendService;
  final MessageSaverBloc _messagesSaverBloc;
  final ChatDatabase _db;
  final Network _network;
  final Channel _channel;

  // ignore: close_sinks
  BehaviorSubject<bool> _isInitFinishedSubject =
      BehaviorSubject(seedValue: false);

  Stream<bool> get isInitFinishedStream => _isInitFinishedSubject.stream;

  bool get isInitFinished => _isInitFinishedSubject.value;

  BehaviorSubject<MessagesList> _messagesListSubject;

  Stream<MessagesList> get messagesListStream => _messagesListSubject.stream;

  MessagesList get messagesList => _messagesListSubject?.value;

  MessageLoaderBloc(this._backendService, this._db, this._messagesSaverBloc,
      this._network, this._channel) {
    addDisposable(subject: _messagesListSubject);
    addDisposable(subject: _isInitFinishedSubject);

    Timer.run(() async {
      _loadStartMessagesFromDatabaseAndSubscribe();
    });
  }

  Future<List<ChatMessage>> loadInitMessages() async {
    List<ChatMessage> messages = <ChatMessage>[];

    // history
    var regularMessages = (await _db.regularMessagesDao
            .getChannelMessagesOrderByDate(_channel.remoteId))
        .map(regularMessageDBToChatMessage);
    var specialMessages =
        (await _db.specialMessagesDao.getChannelMessages(_channel.remoteId))
            .map(specialMessageDBToChatMessage)
            .toList();

    _removeUnnecessarySpecialLoadingMessages(specialMessages);

    messages.addAll(regularMessages);
    messages.addAll(specialMessages);
    _resort(messages);

    return messages;
  }

  void _resort(List<ChatMessage> messages) {
    messages.sort((a, b) {
      return a.date.compareTo(b.date);
    });
  }

  void _onMessagesChanged(
      List<ChatMessage> allMessages,
      List<ChatMessage> newMessages,
      MessageListUpdateType newMessagesPosition) {
    var messagesList = MessagesList.name(
        allMessages: allMessages,
        lastAddedMessages: newMessages,
        messageListUpdateType: newMessagesPosition);
    _messagesListSubject.add(messagesList);
  }

  _removeUnnecessarySpecialLoadingMessages(List<ChatMessage> messages) {
    var lastTextSpecialMessage = findLatestTextSpecialMessage(messages);

    if (lastTextSpecialMessage != null) {
      messages.removeWhere((message) =>
          _isTextSpecialMessage(message) && message != lastTextSpecialMessage);
    }
  }

  ChatMessage findLatestTextSpecialMessage(List<ChatMessage> messages) {
    return messages.lastWhere((message) {
      return _isTextSpecialMessage(message);
    }, orElse: () => null);
  }

  bool _isTextSpecialMessage(ChatMessage message) {
    if (message.isSpecial) {
      var specialMessage = message as SpecialMessage;
      if (specialMessage.specialType == SpecialMessageType.text) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  _loadStartMessagesFromDatabaseAndSubscribe() async {
    _logger.d(() => "init start $disposed");

    var initMessages = await loadInitMessages();
    _messagesListSubject = new BehaviorSubject<MessagesList>(
        seedValue: MessagesList.name(
            allMessages: initMessages,
            lastAddedMessages: initMessages,
            messageListUpdateType:
                MessageListUpdateType.loadedFromLocalDatabase));
    _logger.d(() => "init finish");
    _isInitFinishedSubject.add(true);

    // socket listener
    addDisposable(
        disposable: _messagesSaverBloc.listenForMessages(_network, _channel,
            (messagesForChannel) {
      _addNewMessages(messagesForChannel);
    }));

    addDisposable(
        disposable: _backendService.listenForMessagePreviews(_network, _channel,
            (previewForMessage) {
      _updatePreview(previewForMessage);
    }));

    addDisposable(
        disposable: _backendService.listenForMessagePreviewToggle(
            _network, _channel, (ToggleMessagePreviewData togglePreview) async {
      _onMessagesChanged(
          messagesList.allMessages, [], MessageListUpdateType.notUpdated);
    }));

    addDisposable(
        disposable: _backendService.listenForChannelPreviewToggle(
            _network, _channel, (channelToggle) async {
      _toggleMessages(channelToggle);
    }));
  }

  void _toggleMessages(ToggleChannelPreviewData channelToggle) {
    messagesList.allMessages.forEach((message) {
      if (message is RegularMessage) {
        if (message.previews != null) {
          message.previews.forEach((preview) {
            if (preview.shown != channelToggle.allPreviewsShown) {
              _backendService.togglePreview(
                  _network, _channel, message, preview);
            }
          });
        }
      }
    });
  }

  void _updatePreview(MessagePreviewForRemoteMessageId previewForMessage) {
    var oldMessage = messagesList.allMessages.firstWhere((message) {
      if (message is RegularMessage) {
        var regularMessage = message;

        if (regularMessage.messageRemoteId ==
            previewForMessage.remoteMessageId) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    });

    updatePreview(oldMessage, previewForMessage);

    _onMessagesChanged(
        messagesList.allMessages, [], MessageListUpdateType.notUpdated);
  }

  MessagesForChannel _lastHandledMessages;

  void _addNewMessages(MessagesForChannel messagesForChannel) {
    if (_lastHandledMessages == messagesForChannel) {
      return;
    }

    var isFirstHandle = _lastHandledMessages == null;
    _lastHandledMessages = messagesForChannel;

    var messages = this.messagesList.allMessages;

    var newMessages = messagesForChannel.messages;

    if (newMessages?.isNotEmpty != true) {
      // empty or null
      // maybe during loading history
      return;
    }
    var firstMessage = newMessages.first;

    MessageListUpdateType messageListUpdateType;

    var replaced = false;
    if (isFirstHandle) {
      // sometimes loader receives already display messages during first handle
      // TODO: remove hack. Already handled messages should not be emitted
      if (messages.isNotEmpty) {
        var firstMessage = messages.first;
        if (firstMessage == newMessages.first) {
          messages.remove(firstMessage);
          replaced = true;
        }
      }
    }

    if (messages.isNotEmpty) {
      var lastDate = messages.last.date;
      var firstMessageDate = firstMessage.date;
      if (lastDate.isBefore(firstMessageDate) ||
          lastDate.millisecondsSinceEpoch ==
              firstMessageDate.millisecondsSinceEpoch) {
        // if new message
        messages.addAll(newMessages);
        messageListUpdateType = MessageListUpdateType.newMessagesFromBackend;
      } else if (messages.first.date.isAfter(firstMessageDate)) {
        // if message from history
        messageListUpdateType = MessageListUpdateType.historyFromBackend;
        messages.insertAll(0, newMessages);
      } else {
        // strange case, new message somewhere inside existing messages
        messageListUpdateType = MessageListUpdateType.newMessagesFromBackend;
        messages.addAll(newMessages);
        _resort(messages);
      }
    } else {
      if (replaced) {
        messageListUpdateType = MessageListUpdateType.replacedByBackend;
      } else {
        messageListUpdateType = MessageListUpdateType.loadedFromLocalDatabase;
      }
      messages.addAll(newMessages);
    }
    _logger.d(() => "_addNewMessages $newMessages");

    if (messagesForChannel.isContainsTextSpecialMessage) {
      _removeUnnecessarySpecialLoadingMessages(messages);
    }

    _onMessagesChanged(messages, newMessages, messageListUpdateType);
  }
}
