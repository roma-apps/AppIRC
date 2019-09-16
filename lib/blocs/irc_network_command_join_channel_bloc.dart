import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkCommandJoinChannelBloc extends IRCNetworkCommandBloc {
  final IRCNetwork network;

  IRCNetworkCommandJoinChannelBloc(LoungeService lounge, this.network)
      : super(lounge, network);

  sendJoinIRCCommand(
          {@required String channelName, String password = ""}) async =>
      await lounge.sendJoinChannelMessageRequest(channel,
          JoinIRCCommand(channelName: channelName, channelPassword: password));
}
