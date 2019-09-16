import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_command_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';

import 'package:flutter_appirc/lounge/lounge_service.dart';

const String _connectIRCCommand = "/connect";

class IRCNetworkChannelCommandConnectBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandConnectBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendConnectIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _connectIRCCommand);
}
