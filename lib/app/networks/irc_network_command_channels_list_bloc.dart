import 'dart:core';

import 'package:flutter_appirc/app/networks/irc_network_command_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';

const String _listIRCCommand = "/list";

class IRCNetworkChannelCommandChannelsListBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkChannelCommandChannelsListBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  Future<bool> sendListIRCCommand() async =>
      sendNetworkIRCCommand(ircCommand: _listIRCCommand);
}
