import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_command_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';

import 'package:flutter_appirc/lounge/lounge_service.dart';

const String _exitIRCCommand = "/ignorelist";

class IRCNetworkChannelCommandIgnoreListBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandIgnoreListBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendIgnoreListIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _exitIRCCommand);
}
