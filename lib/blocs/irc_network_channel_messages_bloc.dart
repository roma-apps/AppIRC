import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

const String _logTag = "IRCNetworkChannelMessagesBloc";

class IRCNetworkChannelMessagesBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;

  StreamSubscription<MessageLoungeResponseBody> _messagesSubscription;

  IRCNetworkChannelMessagesBloc(this._lounge, this.channel) {
    _messagesSubscription = _lounge.messagesStream.listen((loungeMessage) {
      if (loungeMessage.chan == channel.remoteId) {
        var msg = loungeMessage.msg;
        var channelMessage = IRCNetworkChannelMessage(
            text: msg.text,
            author: msg.from.nick,
            date: DateTime.parse(msg.time),
            type: msg.type,
            realName: "");
        logi(_logTag,
            "new msg for ${channel.name}: $loungeMessage \n converted to $channelMessage");
        _messages.add(channelMessage);
        _messagesController.sink.add(UnmodifiableListView(_messages));
      }
    });
  }

  final Set<IRCNetworkChannelMessage> _messages = Set<IRCNetworkChannelMessage>();

  final BehaviorSubject<List<IRCNetworkChannelMessage>> _messagesController =
      new BehaviorSubject<List<IRCNetworkChannelMessage>>(seedValue: []);

  Stream<List<IRCNetworkChannelMessage>> get messagesStream =>
      _messagesController.stream;

  void dispose() {
    _messagesController.close();

    _messagesSubscription.cancel();
  }
}
