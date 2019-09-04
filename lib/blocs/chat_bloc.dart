import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/models/thelounge_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';
import 'package:rxdart/rxdart.dart';

class ChatBloc extends Providable {
  final TheLoungeService lounge;

  StreamSubscription<MessageTheLoungeResponseBody> _messagesSubscription;
  StreamSubscription<NetworksTheLoungeResponseBody> _networksSubscription;

  ChatBloc(this.lounge) {
    _messagesSubscription = lounge.outMessages.listen((event) {
      _messageController.sink.add(ChatMessage(event.chan, event.msg));
    });
    _networksSubscription = lounge.outNetworks.listen((event) {
      var newChannels = List<Channel>();

      for (var network in event.networks) {
        for (var loungeChannel in network.channels) {
          newChannels.add(
              Channel(name: loungeChannel.name, remoteId: loungeChannel.id));
        }
      }

      _channelsController.sink.add(UnmodifiableListView(newChannels));

      if (_activeChannel == null && newChannels.length > 0) {
        changeActiveChanel(newChannels[0]);
      }
    });
  }

  final Set<Channel> _channels = Set<Channel>();

  void connect(ChannelsConnectionInfo channelConnectionInfo) =>
      lounge.newNetwork(channelConnectionInfo);

  BehaviorSubject<List<Channel>> _channelsController =
      new BehaviorSubject<List<Channel>>(seedValue: []);

  Stream<List<Channel>> get outChannels => _channelsController.stream;

  BehaviorSubject<ChatMessage> _messageController =
      new BehaviorSubject<ChatMessage>();

  Stream<ChatMessage> get outMessage => _messageController.stream;

  Channel _activeChannel;
  BehaviorSubject<Channel> _activeChannelController =
      new BehaviorSubject<Channel>();

  Stream<Channel> get outActiveChannel => _activeChannelController.stream;

  void _onChannelsChanged() {
    _channelsController.sink.add(UnmodifiableListView(_channels));
  }

  void dispose() {
    _channelsController.close();
    _messageController.close();
    _activeChannelController.close();
    _networksSubscription.cancel();
    _messagesSubscription.cancel();
  }

  void changeActiveChanel(Channel channel) {
    _activeChannel = channel;
    _activeChannelController.sink.add(channel);
  }
}
