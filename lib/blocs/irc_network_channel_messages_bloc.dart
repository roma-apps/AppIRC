import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCNetworkChannelMessagesBloc", enabled: true);

class IRCNetworkChannelMessagesBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;

  StreamSubscription<MessageLoungeResponseBody> _messagesSubscription;
  StreamSubscription<MessageSpecialLoungeResponseBody> _messagesSpecialSubscription;

  IRCNetworkChannelMessagesBloc(this._lounge, this.channel) {
    _messagesSubscription = _lounge.messagesStream.listen((loungeMessage) {
      if (loungeMessage.chan == channel.remoteId) {
        var msg = loungeMessage.msg;
        var ircMessage = toIRCMessage(msg);
        _logger.i(() => "new msg for ${channel.name}: $loungeMessage \n"
            " converted to $ircMessage");
        _messages.add(ircMessage);
        _messagesController.sink.add(UnmodifiableListView(_messages));
      }
    });

    _messagesSpecialSubscription = _lounge.messagesSpecialStream.listen((loungeSpecialMessage) {
      if (loungeSpecialMessage.chan == channel.remoteId) {

        var ircMessage = IRCChatSpecialMessage(loungeSpecialMessage.data);
        _logger.i(() => "new msg:special for ${channel.name}: $loungeSpecialMessage \n"
            " converted to $ircMessage");
        _messages.add(ircMessage);
        _messagesController.sink.add(UnmodifiableListView(_messages));
      }
    });
  }

  final Set<IRCChatMessage> _messages =
      Set<IRCChatMessage>();

  final BehaviorSubject<List<IRCChatMessage>> _messagesController =
      new BehaviorSubject<List<IRCChatMessage>>(seedValue: []);

  Stream<List<IRCChatMessage>> get messagesStream =>
      _messagesController.stream;

  void dispose() {
    _messagesController.close();
    _messagesSpecialSubscription.cancel();

    _messagesSubscription.cancel();
  }
}
