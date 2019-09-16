import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _banListIRCCommand = "/banlist";

class IRCNetworkChannelCommandListBannedBloc extends IRCNetworkChannelCommandBloc {
  IRCNetworkChannelCommandListBannedBloc(
      {@required LoungeService lounge, @required IRCNetworkChannel channel})
      : super(lounge: lounge, channel: channel);

  Future<bool> sendIRCBanListCommand() async =>
      await sendIRCCommand(ircCommand: _banListIRCCommand);
}
