import 'dart:core';

import 'package:flutter_appirc/app/networks/irc_network_command_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';

const String _exitIRCCommand = "/quit";

class IRCNetworkChannelCommandExitBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandExitBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendExitIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _exitIRCCommand);
}
