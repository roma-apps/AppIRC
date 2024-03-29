import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
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
  final ChatBackendService backendService;
  final MessageManagerBloc messagesSaverBloc;
  final ChatDatabase db;
  final Network network;
  final Channel channel;
  final ChannelBloc channelBloc;

  // ignore: close_sinks
  final BehaviorSubject<bool> _isInitFinishedSubject =
      BehaviorSubject.seeded(false);

  Stream<bool> get isInitFinishedStream => _isInitFinishedSubject.stream;

  bool get isInitFinished => _isInitFinishedSubject.value;

  BehaviorSubject<MessagesList> _messagesListSubject;

  Stream<MessagesList> get messagesListStream => _messagesListSubject.stream;

  MessagesList get messagesList => _messagesListSubject?.value;

  MessageLoaderBloc({
    @required this.backendService,
    @required this.db,
    @required this.messagesSaverBloc,
    @required this.network,
    @required this.channel,
    @required this.channelBloc,
  }) {
    addDisposable(subject: _messagesListSubject);
    addDisposable(subject: _isInitFinishedSubject);

    Timer.run(() {
      _loadStartMessagesFromDatabaseAndSubscribe();
    });
  }

  Future<List<ChatMessage>> loadInitMessages() async {
    List<ChatMessage> messages = <ChatMessage>[];

    // history
    var regularMessages =
        (await db.regularMessagesDao.getChannelMessagesOrderByDate(
      channel.remoteId,
    ))
            .map(regularMessageDBToChatMessage);
    var specialMessages = (await db.specialMessagesDao.getChannelMessages(
      channel.remoteId,
    ))
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
      messages.removeWhere(
        (message) =>
            _isTextSpecialMessage(message) && message != lastTextSpecialMessage,
      );
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
      disposable: messagesSaverBloc.listenForMessages(
        network,
        channel,
        (messagesForChannel) {
          if (_messagesListSubject != null) {
            _addNewMessages(network, channel, messagesForChannel);
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
      disposable: backendService.listenForMessagePreviews(
        network: network,
        channel: channel,
        listener: (previewForMessage) {
          _updatePreview(previewForMessage);
        },
      ),
    );

    addDisposable(
      disposable: backendService.listenForMessagePreviewToggle(
        network: network,
        channel: channel,
        listener: (ToggleMessagePreviewData togglePreview) async {
          _onMessagesChanged(
              messagesList.allMessages, [], MessageListUpdateType.notUpdated);
        },
      ),
    );

    addDisposable(
      disposable: backendService.listenForChannelPreviewToggle(
        network: network,
        channel: channel,
        listener: (channelToggle) async {
          _toggleMessages(channelToggle);
        },
      ),
    );
  }

  void _toggleMessages(ToggleChannelPreviewData channelToggle) {
    messagesList.allMessages.forEach(
      (message) {
        if (message is RegularMessage) {
          if (message.previews != null) {
            message.previews.forEach(
              (preview) {
                if (preview.shown != channelToggle.allPreviewsShown) {
                  backendService.togglePreview(
                    network: network,
                    channel: channel,
                    message: message,
                    preview: preview,
                  );
                }
              },
            );
          }
        }
      },
    );
  }

  void _updatePreview(MessagePreviewForRemoteMessageId previewForMessage) {
    var oldMessage = messagesList.allMessages.firstWhere(
      (message) {
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
      },
    );

    updatePreview(oldMessage, previewForMessage);

    _onMessagesChanged(
      messagesList.allMessages,
      [],
      MessageListUpdateType.notUpdated,
    );
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
        await db.regularMessagesDao.getOldestChannelMessage(channel.remoteId);

    // lounge messages id given in chronological order
    if (oldestLocalMessage.messageRemoteId >
        newestRemoteMessage.messageRemoteId) {
      // simple load history from remote
      return;
    } else {
      var newestLocalMessage =
          await db.regularMessagesDao.getNewestChannelMessage(channel.remoteId);
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

          await backendService.loadMoreHistory(
            network: network,
            channel: channel,
            lastMessageId: oldestRemoteMessage.messageRemoteId,
          );
        }
        return;
      } else {
        _logger.shout(() => "_checkAdditionalLoadMore: Invalid case");
      }
    }
  }
}
