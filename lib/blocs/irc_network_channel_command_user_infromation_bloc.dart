import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _userInformationIRCCommand = "/whois";

class IRCNetworkChannelCommandUserInformationBloc
    extends IRCNetworkChannelCommandBloc {
  final String username;

  IRCNetworkChannelCommandUserInformationBloc(
      {@required LoungeService lounge,
      @required IRCNetworkChannel channel,
      @required this.username})
      : super(lounge: lounge, lobbyChannel: channel);

  Future<bool> sendIRCUserInformationCommand() async => await sendIRCCommand(
      ircCommand: _userInformationIRCCommand, args: username);
}
