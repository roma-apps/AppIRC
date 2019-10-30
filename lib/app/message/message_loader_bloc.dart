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

  BehaviorSubject<List<ChatMessage>> _messagesSubject;

  Stream<List<ChatMessage>> get messagesStream => _messagesSubject.stream;
  List<ChatMessage> get messages => _messagesSubject?.value;

  MessageLoaderBloc(this._backendService, this._db, this._messagesSaverBloc,
      this._network, this._channel) {
    addDisposable(subject: _messagesSubject);
    addDisposable(subject: _isInitFinishedSubject);

    Timer.run(() async {
      _loadStartMessagesFromDatabase();
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
            .map(specialMessageDBToChatMessage);

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

  void _onMessagesChanged() {
    _logger.d(() => "_onMessagesChanged ${messages.length}"
        "closed ${_messagesSubject.isClosed}");

    _messagesSubject.add(messages);
  }

  ChatMessage findLatestTextSpecialMessage() {
    return messages.lastWhere((message) {
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
    }, orElse: () => null);
  }

  _loadStartMessagesFromDatabase() async {
    _logger.d(() => "init start $disposed");

    _messagesSubject = new BehaviorSubject<List<ChatMessage>>(
        seedValue: await loadInitMessages());
    _logger.d(() => "init finish");
    _isInitFinishedSubject.add(true);

    // socket listener
    addDisposable(
        disposable: _messagesSaverBloc.listenForMessages(_network, _channel,
            (newMessage) {
      _addNewMessage(newMessage);
    }));

    addDisposable(
        disposable: _backendService.listenForMessagePreviews(_network, _channel,
            (previewForMessage) {
      _updatePreview(previewForMessage);
    }));

    addDisposable(
        disposable: _backendService.listenForMessagePreviewToggle(
            _network, _channel, (ToggleMessagePreviewData togglePreview) async {
      _onMessagesChanged();
    }));

    addDisposable(
        disposable: _backendService.listenForChannelPreviewToggle(
            _network, _channel, (channelToggle) async {
      _toggleMessages(channelToggle);
    }));
  }

  void _toggleMessages(ToggleChannelPreviewData channelToggle) {
    messages.forEach((message) {
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
    var oldMessage = messages.firstWhere((message) {
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

    _onMessagesChanged();
  }

  void _addNewMessage(ChatMessage newMessage) {

    var messages = this.messages;
    var lastMessage = messages.last;
    if(lastMessage is RegularMessage && newMessage is RegularMessage) {
      if(lastMessage.messageRemoteId == newMessage.messageRemoteId) {
        // TODO: hack for bug in lounge
        // sometimes lounge emit last message twice
        _logger.w(() => "_addNewMessage dublicated message not added "
            "$newMessage");
        return;
      }
    }

    if (messages.isNotEmpty) {
      if (messages.last.date.isBefore(newMessage.date)) {
        // if new message
        messages.add(newMessage);
      } else if (messages.first.date.isAfter(newMessage.date)) {
        // if message from history
        messages.insert(0, newMessage);
      } else {
        // strange case, new message somewhere inside existing messages
        messages.add(newMessage);
        _resort(messages);
      }
    } else {
      messages.add(newMessage);
    }
    _logger.d(() => "_addNewMessage $newMessage");

    if (newMessage.chatMessageType == ChatMessageType.special) {
      SpecialMessage latestTextMessage = findLatestTextSpecialMessage();

      if (latestTextMessage != null) {
        return messages.removeWhere((message) {
          if (message.isSpecial) {
            var specialMessage = message as SpecialMessage;
            if (specialMessage.specialType == SpecialMessageType.text) {
              return message != latestTextMessage;
            } else {
              return false;
            }
          } else {
            return false;
          }
        });
      }
    }
    _onMessagesChanged();
  }
}
