import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';
import 'package:rxdart/rxdart.dart';

const String _logTag = "ChannelBloc";

class ChannelBloc extends Providable {
  final TheLoungeService lounge;
  final ChatBloc chatBloc;
  final Channel channel;

  StreamSubscription<ChatMessage> subscription;

  ChannelBloc(this.lounge, this.chatBloc, this.channel) {
    subscription = chatBloc.outMessage.listen((chatMessage) {
      if (chatMessage.channelId == channel.remoteId) {
        var channelMessage = ChannelMessage.name(
            text: chatMessage.msg.text,
            author: chatMessage.msg.from.nick,
            date: DateTime.parse(chatMessage.msg.time),
            type: chatMessage.msg.type,
            realName: "");
        logi(_logTag,
            "new msg for ${channel.name}: $chatMessage \n converted to $channelMessage");
        _messages.add(channelMessage);
        _messagesController.sink.add(UnmodifiableListView(_messages));
      }
    });
  }

  Set<ChannelMessage> _messages = Set<ChannelMessage>();

  BehaviorSubject<List<ChannelMessage>> _messagesController =
      new BehaviorSubject<List<ChannelMessage>>(seedValue: []);

  Stream<List<ChannelMessage>> get outMessages => _messagesController.stream;

  void dispose() {
    _messagesController.close();
    subscription.cancel();
  }

  sendMessage(String text) => lounge.sendChatMessage(channel.remoteId, text);
}
