import 'dart:async';
import 'dart:collection';
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

var _logger = MyLogger(
    logTag: "NetworkChannelMessagesLoaderBloc", enabled: true);


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

  NetworkChannelMessagesLoaderBloc(this.backendService, this.db, this.network,
      this.networkChannel) {
    addDisposable(subject: _messagesController);


    // socket listener
    addDisposable(disposable: backendService.listenForMessages(
        network, networkChannel, (newMessage) {
      _currentMessages.add(newMessage);
      _onMessagesChanged();
    }));

    // history
    db.regularMessagesDao.getChannelMessages(networkChannel.remoteId).then((
        messagesDB) {
      var messages = messagesDB.map(_regularMessageDBToChatMessage);
      _currentMessages.addAll(messages);
      _onMessagesChanged();
    });
    db.specialMessagesDao.getChannelMessages(networkChannel.remoteId).then((
        messagesDB) {
      var messages = messagesDB.map(_specialMessageDBToChatMessage);
      _currentMessages.addAll(messages);
      _onMessagesChanged();
    });
  }

  void _onMessagesChanged() {
    _messagesController.add(_currentMessages);
  }

  RegularMessage _regularMessageDBToChatMessage(RegularMessageDB messageDB) =>
      RegularMessage.name(
          messageDB.channelRemoteId,
          command: messageDB.command,
          hostMask: messageDB.hostMask,
          text: messageDB.text,
          params: _convertParams(messageDB),
          regularMessageType: regularMessageTypeIdToType(messageDB.regularMessageTypeId),
          self: messageDB.self != null ? messageDB.self == 0 ? false : true : null,
          highlight: messageDB.highlight != null ? messageDB.highlight == 0 ? false : true : null,
          previews: _convertPreviews(messageDB),
          date: DateTime.fromMicrosecondsSinceEpoch(messageDB.dateMicrosecondsSinceEpoch),
          fromRemoteId: messageDB.fromRemoteId,
          fromNick: messageDB.fromNick,
          fromMode: messageDB.fromMode, newNick: messageDB.newNick);

  List<String> _convertParams(RegularMessageDB messageDB) {
    var decoded = json.decode(messageDB.paramsJsonEncoded);

    if(decoded == null) {
      return null;
    } else if(decoded is List<dynamic>) {
      decoded = (decoded as List<dynamic>).map((item) => item.toString()).toList();
    }
    return decoded;
  }

  _convertPreviews(RegularMessageDB messageDB) => json.decode(messageDB.previewsJsonEncoded);

  SpecialMessage _specialMessageDBToChatMessage(SpecialMessageDB messageDB) =>
      SpecialMessage.name(channelRemoteId: messageDB.channelRemoteId,
          data: json.decode(messageDB.dataJsonEncoded),
          specialType: specialMessageTypeIdToType(messageDB.specialTypeId));
}
