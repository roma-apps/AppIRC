import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _joinIRCCommand = "/join";

class IRCNetworkCommandJoinChannelBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkCommandJoinChannelBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendJoinIRCCommand(
          {@required String channelName, String password = ""}) async =>
      sendNetworkIRCCommand(
          ircCommand: _joinIRCCommand, args: "$channelName $password");
}
