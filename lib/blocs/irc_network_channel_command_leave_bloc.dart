import 'dart:core';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_command_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';


class IRCNetworkChannelCommandLeaveBloc extends IRCNetworkChannelCommandBloc {
  IRCNetworkChannelCommandLeaveBloc(
      {@required LoungeService lounge, @required IRCNetworkChannel channel})
      : super(lounge: lounge, channel: channel);

  sendCloseIRCCommand(
      {@required String channelName}) async =>
      await lounge.sendCloseChannelMessageRequest(channel,
          CloseIRCCommand(channelName: channelName));
}
