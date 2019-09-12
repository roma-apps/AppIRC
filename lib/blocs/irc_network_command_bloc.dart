import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkCommandBloc extends IRCNetworkChannelCommandBloc {
  final IRCNetwork network;

  IRCNetworkCommandBloc(LoungeService lounge, this.network)
      : super(lounge: lounge, channel: network.lobbyChannel);

  Future<bool> sendNetworkIRCCommand(
          {@required String ircCommand, String args = ""}) async =>
      channel == null
          ? false
          : await sendIRCCommand(ircCommand: ircCommand, args: args);
}