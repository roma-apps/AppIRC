import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';

import 'package:flutter_appirc/lounge/lounge_service.dart';

class IRCNetworkChannelCommandBloc extends AsyncOperationBloc {
  final LoungeService lounge;
  final IRCNetworkChannel channel;

  IRCNetworkChannelCommandBloc({@required this.lounge, @required this.channel});

  sendIRCCommand({@required String ircCommand, String args = ""}) async =>
      doAsyncOperation(() async => await lounge.sendChatMessageRequest(
          channel.remoteId, "$ircCommand $args"));

  @override
  void dispose() {
    super.dispose();
  }
}
