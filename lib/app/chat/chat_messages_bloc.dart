import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCNetworkChannelMessagesBloc", enabled: true);

class NetworkChannelMessagesBloc extends Providable {
  final ChatOutputBackendService backendService;
  final Network network;
  final NetworkChannel networkChannel;


  // ignore: close_sinks
  var _messagesController =
  new BehaviorSubject<List<IRCChatMessage>>(seedValue: []);

  Stream<List<IRCChatMessage>> get messagesStream => _messagesController.stream;

  NetworkChannelMessagesBloc(this.backendService, this.network, this.networkChannel) {
    addDisposable(subject: _messagesController);

    backendService.listenForMessages(network, networkChannel, (newMessage) {
      var list = _messagesController.value;
      list.add(newMessage);
      _messagesController.add(list);
    });
  }
}
