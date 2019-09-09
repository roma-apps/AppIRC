import 'dart:async';

import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCNetworkChannelTopicBloc", enabled: true);

class IRCNetworkChannelTopicBloc extends Providable {
  final LoungeService lounge;
  final IRCNetworkChannel channel;

  StreamSubscription<TopicLoungeResponseBody> _topicSubscription;

  final BehaviorSubject<String> _topicController =
      new BehaviorSubject<String>();

  Stream<String> get outTopic => _topicController.stream;

  IRCNetworkChannelTopicBloc(this.lounge, this.channel) {
    _logger.i(() => "Create topic bloc for ${channel.name}");

    _topicSubscription = lounge.topicStream.listen((loungeMessage) {
      if (loungeMessage.chan == channel.remoteId) {
        _logger
            .i(() => "new topic for ${channel.name} is ${loungeMessage.topic}");
        _topicController.add(loungeMessage.topic);
      }
    });
  }

  @override
  void dispose() {
    _topicController.close();
    _topicSubscription.cancel();
  }
}
