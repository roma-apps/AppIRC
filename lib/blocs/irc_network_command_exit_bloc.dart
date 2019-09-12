import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _exitIRCCommand = "/quit";

class IRCNetworkChannelCommandExitBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandExitBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendExitIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _exitIRCCommand);
}
