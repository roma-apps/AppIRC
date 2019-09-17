import 'dart:core';

import 'package:flutter_appirc/app/networks/irc_network_command_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';

const String _disconnectIRCCommand = "/disconnect";

class IRCNetworkChannelCommandDisconnectBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandDisconnectBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendDisconnectIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _disconnectIRCCommand);
}
