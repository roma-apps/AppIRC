import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "NetworkChannelMessagesLoaderBloc", enabled: true);


class NetworkChannelMessagesLoaderBloc extends Providable {
  final ChatDatabase db;
  final Network network;
  final NetworkChannel networkChannel;

  List<SpecialMessage> _lastSpecialMessages = [];
  List<RegularMessage> _lastRegularMessages = [];

  // ignore: close_sinks
  var _messagesController =
      new BehaviorSubject<List<ChatMessage>>(seedValue: []);

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  NetworkChannelMessagesLoaderBloc(this.db, this.network, this.networkChannel) {
    addDisposable(subject: _messagesController);

    addDisposable(
        streamSubscription: db.regularMessagesDao
            .getChannelMessagesStream(networkChannel.remoteId)
            .listen((messageList) {
      _lastRegularMessages = messageList;
      _onMessagesChanged();
    }));
    addDisposable(
        streamSubscription: db.specialMessagesDao
            .getChannelMessagesStream(networkChannel.remoteId)
            .listen((messageList) {
      _lastSpecialMessages = messageList;
      _onMessagesChanged();
    }));
  }

  void _onMessagesChanged() {
    var messageList = <ChatMessage>[];
    messageList.addAll(_lastRegularMessages);
    messageList.addAll(_lastSpecialMessages);

    // TODO: don't reload from db all messages on change
    // Loader block should only load previous messages from db
    _messagesController.add(messageList);
  }
}
