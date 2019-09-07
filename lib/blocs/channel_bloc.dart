import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

const String _logTag = "ChannelBloc";

class ChannelTopicBloc extends Providable {
  final LoungeService lounge;
  final Channel channel;

  StreamSubscription<TopicLoungeResponseBody> _topicSubscription;

  ChannelTopicBloc(this.lounge, this.channel) {
    logi(_logTag, "Create topic bloc for ${channel.name}");

    _topicSubscription = lounge.outTopic.listen((loungeMessage) {
      if (loungeMessage.chan == channel.remoteId) {
        logi(_logTag, "new topic for ${channel.name} is ${loungeMessage.topic}");
        _topicController.add(loungeMessage.topic);
      }
    });
  }

  BehaviorSubject<String> _topicController = new BehaviorSubject<String>();

  Stream<String> get outTopic => _topicController.stream;

  @override
  void dispose() {
    _topicController.close();
    _topicSubscription.cancel();
  }


}

class ChannelBloc extends Providable {
  final LoungeService lounge;
  final Channel channel;

  StreamSubscription<MessageLoungeResponseBody> _messagesSubscription;


  ChannelBloc(this.lounge, this.channel) {
    _messagesSubscription = lounge.outMessages.listen((loungeMessage) {
      if (loungeMessage.chan == channel.remoteId) {
        var msg = loungeMessage.msg;
        var channelMessage = ChannelMessage.name(
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

  Set<ChannelMessage> _messages = Set<ChannelMessage>();

  BehaviorSubject<List<ChannelMessage>> _messagesController =
      new BehaviorSubject<List<ChannelMessage>>(seedValue: []);

  Stream<List<ChannelMessage>> get outMessages => _messagesController.stream;


  void dispose() {
    _messagesController.close();

    _messagesSubscription.cancel();

  }

  sendMessage(String text) => lounge.sendChatMessageRequest(channel.remoteId, text);
}
