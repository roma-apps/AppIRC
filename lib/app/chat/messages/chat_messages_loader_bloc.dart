import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_saver_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_db.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/special/messages_special_db.dart';
import 'package:flutter_appirc/app/message/special/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger =
    MyLogger(logTag: "NetworkChannelMessagesLoaderBloc", enabled: true);

class NetworkChannelMessagesLoaderBloc extends Providable {
  final ChatBackendService backendService;
  final NetworkChannelMessagesSaverBloc messagesSaverBloc;
  final ChatDatabase db;
  final Network network;
  final NetworkChannel networkChannel;

  // ignore: close_sinks
  BehaviorSubject<bool> _isInitFinishedSubject =
      BehaviorSubject(seedValue: false);
  Stream<bool> get isInitFinishedStream => _isInitFinishedSubject.stream;
  bool get isInitFinished => _isInitFinishedSubject.value;

  BehaviorSubject<List<ChatMessage>> _messagesController;

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;
  List<ChatMessage> get messages => _messagesController?.value;

  NetworkChannelMessagesLoaderBloc(this.backendService, this.db,
      this.messagesSaverBloc, this.network, this.networkChannel) {
    addDisposable(subject: _messagesController);
    addDisposable(subject: _isInitFinishedSubject);

    Timer.run(() async {
      _logger.d(() => "init start $disposed");

      _messagesController = new BehaviorSubject<List<ChatMessage>>(
          seedValue: await loadInitMessages());
      _logger.d(() => "init finish");
      _isInitFinishedSubject.add(true);

      // socket listener
      addDisposable(
          disposable: messagesSaverBloc
              .listenForMessages(network, networkChannel, (newMessage) {
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

        if (newMessage.chatMessageType == ChatMessageType.SPECIAL) {
          _onSpecialMessagesChanged();
        }
        _onMessagesChanged();
      }));

      addDisposable(
          disposable: backendService.listenForMessagePreviews(
              network, networkChannel, (previewForMessage) {
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
      }));

      addDisposable(
          disposable: backendService
              .listenForMessagePreviewToggle(network, networkChannel,
                  (MessageTogglePreview togglePreview) async {
        _onMessagesChanged();
      }));

      addDisposable(
          disposable: backendService.listenForChannelPreviewToggle(
              network, networkChannel, (channelToggle) async {
        messages.forEach((message) {
          if (message is RegularMessage) {
            if (message.previews != null) {
              message.previews.forEach((preview) {
                if (preview.shown != channelToggle.allPreviewsShown) {
                  backendService.togglePreview(
                      network, networkChannel, message, preview);
                }
              });
            }
          }
        });
      }));


    });
  }

  Future<List<ChatMessage>> loadInitMessages() async {
    List<ChatMessage> messages = <ChatMessage>[];

    // history
    var regularMessages = (await db.regularMessagesDao
            .getChannelMessagesOrderByDate(networkChannel.remoteId))
        .map(regularMessageDBToChatMessage);
    var specialMessages = (await db.specialMessagesDao
            .getChannelMessages(networkChannel.remoteId))
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
        "closed ${_messagesController.isClosed}");

    _messagesController.add(messages);
  }

  void _onSpecialMessagesChanged() {
    SpecialMessage latestTextMessage = messages.lastWhere((message) {
      if (message.isSpecial) {
        var specialMessage = message as SpecialMessage;
        if (specialMessage.specialType == SpecialMessageType.TEXT) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }, orElse: () => null);

    if (latestTextMessage != null) {
      messages.removeWhere((message) {
        if (message.isSpecial) {
          var specialMessage = message as SpecialMessage;
          if (specialMessage.specialType == SpecialMessageType.TEXT) {
            return specialMessage != latestTextMessage;
          } else {
            return false;
          }
        } else {
          return false;
        }
      });
    }
  }
}
