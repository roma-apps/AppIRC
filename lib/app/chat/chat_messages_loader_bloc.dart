import 'dart:async';
import 'dart:convert';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
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

  List<ChatMessage> _currentMessages = [];

  // ignore: close_sinks
  var _messagesController =
      new BehaviorSubject<List<ChatMessage>>(seedValue: []);

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  NetworkChannelMessagesLoaderBloc(
      this.backendService, this.db, this.network, this.networkChannel) {
    addDisposable(subject: _messagesController);


    Timer.run( () async {

      // history
      var regularMessages = (await db.regularMessagesDao
          .getChannelMessages(networkChannel.remoteId)).map(_regularMessageDBToChatMessage);
      var specialMessages = (await db.specialMessagesDao
          .getChannelMessages(networkChannel.remoteId)).map(_specialMessageDBToChatMessage);


      _currentMessages.addAll(regularMessages);
      _currentMessages.addAll(specialMessages);
      _currentMessages.sort((a, b) {
        return a.date.compareTo(b.date);
      });
      _onMessagesChanged();
      // socket listener
      addDisposable(
          disposable: backendService.listenForMessages(network, networkChannel,
                  (newMessage) {
                _currentMessages.add(newMessage);
                if (newMessage.chatMessageType == ChatMessageType.SPECIAL) {
                  _onSpecialMessagesChanged();
                }
                _onMessagesChanged();
              }));

    });


  }

  void _onMessagesChanged() {
    _messagesController.add(_currentMessages);
  }

  RegularMessage _regularMessageDBToChatMessage(RegularMessageDB messageDB) =>
      RegularMessage.name(messageDB.channelRemoteId,
          command: messageDB.command,
          hostMask: messageDB.hostMask,
          text: messageDB.text,
          params: _convertParams(messageDB),
          regularMessageType:
              regularMessageTypeIdToType(messageDB.regularMessageTypeId),
          self: messageDB.self != null
              ? messageDB.self == 0 ? false : true
              : null,
          highlight: messageDB.highlight != null
              ? messageDB.highlight == 0 ? false : true
              : null,
          previews: _convertPreviews(messageDB),
          date: DateTime.fromMicrosecondsSinceEpoch(
              messageDB.dateMicrosecondsSinceEpoch),
          fromRemoteId: messageDB.fromRemoteId,
          fromNick: messageDB.fromNick,
          fromMode: messageDB.fromMode,
          newNick: messageDB.newNick);

  List<String> _convertParams(RegularMessageDB messageDB) {
    var decoded = json.decode(messageDB.paramsJsonEncoded);

    if (decoded == null) {
      return null;
    } else if (decoded is List<dynamic>) {
      decoded =
          (decoded as List<dynamic>).map((item) => item.toString()).toList();
    }
    return decoded;
  }

  _convertPreviews(RegularMessageDB messageDB) =>
      json.decode(messageDB.previewsJsonEncoded);

  SpecialMessage _specialMessageDBToChatMessage(SpecialMessageDB messageDB) {
    var type = specialMessageTypeIdToType(messageDB.specialTypeId);
    var decodedJson = json.decode(messageDB.dataJsonEncoded);
    var body;
    switch (type) {
      case SpecialMessageType.WHO_IS:
        body = WhoIsSpecialMessageBody.fromJson(decodedJson);
        break;
      case SpecialMessageType.CHANNELS_LIST_ITEM:
        body = NetworkChannelInfoSpecialMessageBody.fromJson(decodedJson);
        break;
      case SpecialMessageType.TEXT:
        body = TextSpecialMessageBody.fromJson(decodedJson);
        break;
    }

    return SpecialMessage.name(
        channelRemoteId: messageDB.channelRemoteId,
        data: body,
        specialType: type, date: DateTime.fromMicrosecondsSinceEpoch(messageDB.dateMicrosecondsSinceEpoch));
  }

  void _onSpecialMessagesChanged() {
    SpecialMessage latestTextMessage = _currentMessages.lastWhere((message) {
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
      _currentMessages.removeWhere((message) {
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
