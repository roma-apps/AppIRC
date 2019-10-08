import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_messages_saver_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_db.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_db.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger =
    MyLogger(logTag: "NetworkChannelMessagesLoaderBloc", enabled: true);

class NetworkChannelMessagesLoaderBloc extends Providable {
  final ChatOutputBackendService backendService;
  final ChatDatabase db;
  final Network network;
  final NetworkChannel networkChannel;

  List<ChatMessage> currentMessages = [];

  // ignore: close_sinks
  var _messagesController =
      new BehaviorSubject<List<ChatMessage>>(seedValue: []);

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  NetworkChannelMessagesLoaderBloc(
      this.backendService, this.db, this.network, this.networkChannel) {
    addDisposable(subject: _messagesController);

    Timer.run(() async {
      // history
      var regularMessages = (await db.regularMessagesDao
              .getChannelMessages(networkChannel.remoteId))
          .map(regularMessageDBToChatMessage);
      var specialMessages = (await db.specialMessagesDao
              .getChannelMessages(networkChannel.remoteId))
          .map(specialMessageDBToChatMessage);

      currentMessages.addAll(regularMessages);
      currentMessages.addAll(specialMessages);
      currentMessages.sort((a, b) {
        return a.date.compareTo(b.date);
      });
      _onMessagesChanged();
      // socket listener
      addDisposable(
          disposable: backendService.listenForMessages(network, networkChannel,
              (newMessage) {
        currentMessages.add(newMessage);
        if (newMessage.chatMessageType == ChatMessageType.SPECIAL) {
          _onSpecialMessagesChanged();
        }
        _onMessagesChanged();
      }));

      addDisposable(
          disposable: backendService.listenForMessagePreviews(
              network, networkChannel, (previewForMessage) {
        var oldMessage = currentMessages.firstWhere((message) {

          if (message is RegularMessage) {
            var regularMessage = message;

            if (regularMessage.messageRemoteId == message.messageRemoteId) {
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
    });
  }

  void _onMessagesChanged() {
    _messagesController.add(currentMessages);
  }

  void _onSpecialMessagesChanged() {
    SpecialMessage latestTextMessage = currentMessages.lastWhere((message) {
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
      currentMessages.removeWhere((message) {
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
