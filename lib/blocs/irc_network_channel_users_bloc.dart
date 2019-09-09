import 'dart:async';
import 'dart:collection';

import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_user_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "IRCNetworkChannelUsersBloc", enabled: true);

var _updateNamesDuration = Duration(seconds: 30);

class IRCNetworkChannelUsersBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;
  Timer _updateTimer;

  StreamSubscription<NamesLoungeResponseBody> _namesSubscription;

  IRCNetworkChannelUsersBloc(this._lounge, this.channel) {
    _namesSubscription = _lounge.namesStream.listen((loungeMessage) {
      if (loungeMessage.id == channel.remoteId) {
        var users = loungeMessage.users;

        var channelUsers = users.map((loungeUser) => IRCNetworkChannelUser(
            mode: loungeUser.mode, nick: loungeUser.nick));

        _logger.i(() => "new users for ${channel.name}: $loungeMessage \n"
            " converted to $channelUsers");
        _users.clear();
        _users.addAll(channelUsers);
        _usersController.sink.add(UnmodifiableListView(_users));
      }
    });

    _updateUsers();

    _updateTimer = Timer.periodic(_updateNamesDuration, (_) {
      _updateUsers();
    });
  }

  void _updateUsers() {
    _lounge.sendNamesRequest(channel);
  }

  final Set<IRCNetworkChannelUser> _users = Set<IRCNetworkChannelUser>();

  final BehaviorSubject<List<IRCNetworkChannelUser>> _usersController =
      new BehaviorSubject<List<IRCNetworkChannelUser>>(seedValue: []);

  Stream<List<IRCNetworkChannelUser>> get usersStream =>
      _usersController.stream;

  void dispose() {
    _usersController.close();

    _namesSubscription.cancel();

    _updateTimer.cancel();
  }
}
