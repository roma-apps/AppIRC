import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_db.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_db.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("message_loader_bloc.dart");

class MessageLoaderBloc extends DisposableOwner {
  final ChatBackendService _backendService;
  final MessageManagerBloc _messagesSaverBloc;
  final ChatDatabase _db;
  final Network _network;
  final Channel _channel;

  // ignore: close_sinks
  final BehaviorSubject<bool> _isInitFinishedSubject =
      BehaviorSubject.seeded(false);

  Stream<bool> get isInitFinishedStream => _isInitFinishedSubject.stream;

  bool get isInitFinished => _isInitFinishedSubject.value;

  BehaviorSubject<MessagesList> _messagesListSubject;

  Stream<MessagesList> get messagesListStream => _messagesListSubject.stream;

  MessagesList get messagesList => _messagesListSubject?.value;

  MessageLoaderBloc(this._backendService, this._db, this._messagesSaverBloc,
      this._network, this._channel) {
    addDisposable(subject: _messagesListSubject);
    addDisposable(subject: _isInitFinishedSubject);

    Timer.run(() {
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
    MessageListUpdateType newMessagesPosition,
  ) {
    var messagesList = MessagesList(
      allMessages: allMessages,
      lastAddedMessages: newMessages,
      messageListUpdateType: newMessagesPosition,
    );
    _messagesListSubject.add(messagesList);
  }

  void _removeUnnecessarySpecialLoadingMessages(List<ChatMessage> messages) {
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

  Future _loadStartMessagesFromDatabaseAndSubscribe() async {
    _logger.fine(() => "init start isDisposed $isDisposed");

    var receivedMessages = <List<ChatMessage>>[];
    // socket listener
    addDisposable(
      disposable: _messagesSaverBloc.listenForMessages(
        _network,
        _channel,
        (messagesForChannel) {
          if (_messagesListSubject != null) {
            _addNewMessages(_network, _channel, messagesForChannel);
          } else {
            receivedMessages.add(messagesForChannel.messages);
          }
        },
      ),
    );

    var initMessages = await loadInitMessages();

    if (receivedMessages.isNotEmpty) {
      receivedMessages.forEach((messages) {
        initMessages.addAll(messages);
      });
    }
    _messagesListSubject = BehaviorSubject<MessagesList>.seeded(
      MessagesList(
        allMessages: initMessages,
        lastAddedMessages: initMessages,
        messageListUpdateType: MessageListUpdateType.loadedFromLocalDatabase,
      ),
    );
    _logger.fine(() => "init finish");
    _isInitFinishedSubject.add(true);

    addDisposable(
      disposable: _backendService.listenForMessagePreviews(
        _network,
        _channel,
        (previewForMessage) {
          _updatePreview(previewForMessage);
        },
      ),
    );

    addDisposable(
      disposable: _backendService.listenForMessagePreviewToggle(
        _network,
        _channel,
        (ToggleMessagePreviewData togglePreview) async {
          _onMessagesChanged(
              messagesList.allMessages, [], MessageListUpdateType.notUpdated);
        },
      ),
    );

    addDisposable(
      disposable: _backendService.listenForChannelPreviewToggle(
        _network,
        _channel,
        (channelToggle) async {
          _toggleMessages(channelToggle);
        },
      ),
    );
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

  void _addNewMessages(
      Network network, Channel channel, MessagesForChannel messagesForChannel) {
    if (messagesForChannel.isNeedCheckAdditionalLoadMore) {
      // lounge send maximum 100 newest messages on start
      // AppIRC should check local storage to identify missed and load them

      _checkAdditionalLoadMore(network, channel, messagesForChannel);
    }

    var messages = messagesList.allMessages;

    var newMessages = messagesForChannel.messages;

    if (newMessages?.isNotEmpty != true) {
      // empty or null
      // maybe during loading history
      return;
    }
    var newFirstMessage = newMessages.first;

    MessageListUpdateType messageListUpdateType;

    if (messages.isNotEmpty) {
      var lastDate = messages.last.date;
      var firstMessageDate = newFirstMessage.date;
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
      messageListUpdateType = MessageListUpdateType.loadedFromLocalDatabase;

      messages.addAll(newMessages);
    }
    _logger.fine(() => "_addNewMessages $newMessages");

    if (messagesForChannel.isContainsTextSpecialMessage) {
      _removeUnnecessarySpecialLoadingMessages(messages);
    }

    _onMessagesChanged(messages, newMessages, messageListUpdateType);
  }

  Future<void> _checkAdditionalLoadMore(
    Network network,
    Channel channel,
    MessagesForChannel messagesForChannel,
  ) async {
    // lounge send maximum 100 newest messages on start
    // AppIRC should check local storage to identify missed and load them

    var messages = messagesForChannel.messages;
    if (messages?.isNotEmpty != true) {
      return;
    }

    var oldestRemoteMessage = messages.firstWhere(
        (message) => message is RegularMessage,
        orElse: () => null) as RegularMessage;
    var newestRemoteMessage = messages.lastWhere(
        (message) => message is RegularMessage,
        orElse: () => null) as RegularMessage;

    if (oldestRemoteMessage == null || newestRemoteMessage == null) {
      return;
    }

    var oldestLocalMessage =
        await _db.regularMessagesDao.getOldestChannelMessage(channel.remoteId);

    // lounge messages id given in chronological order
    if (oldestLocalMessage.messageRemoteId >
        newestRemoteMessage.messageRemoteId) {
      // simple load history from remote
      return;
    } else {
      var newestLocalMessage = await _db.regularMessagesDao
          .getNewestChannelMessage(channel.remoteId);
      if (newestLocalMessage.messageRemoteId <
          newestRemoteMessage.messageRemoteId) {
        // new messages after reconnecting or init
        if (newestLocalMessage.messageRemoteId <
            oldestRemoteMessage.messageRemoteId) {
          // remote message is newer than local
          // we should try load more from remote

          _logger.fine(() => "_checkAdditionalLoadMore loadMore "
              "newestLocalMessage $newestLocalMessage"
              "oldestRemoteMessage $oldestRemoteMessage");

          await _backendService.loadMoreHistory(
            network,
            channel,
            oldestRemoteMessage.messageRemoteId,
          );
        }
        return;
      } else {
        _logger.shout(() => "_checkAdditionalLoadMore: Invalid case");
      }
    }
  }
}
