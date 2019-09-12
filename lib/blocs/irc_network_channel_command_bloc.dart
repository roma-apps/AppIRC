import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkChannelCommandBloc extends AsyncOperationBloc {
  final LoungeService lounge;
  final IRCNetworkChannel channel;

  IRCNetworkChannelCommandBloc(
      {@required this.lounge,
      @required this.channel});

  sendIRCCommand({@required String ircCommand, String args = ""}) async {
    onOperationStarted();

    var result = await lounge.sendChatMessageRequest(
        channel.remoteId, "$ircCommand $args");
    onOperationFinished();

    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
