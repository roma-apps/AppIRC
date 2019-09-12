import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _disconnectIRCCommand = "/disconnect";

class IRCNetworkChannelCommandDisconnectBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandDisconnectBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendDisconnectIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _disconnectIRCCommand);
}
