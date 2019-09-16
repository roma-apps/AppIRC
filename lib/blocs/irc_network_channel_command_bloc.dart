import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkChannelCommandBloc extends AsyncOperationBloc {
  final LoungeService lounge;
  final IRCNetworkChannel lobbyChannel;

  IRCNetworkChannelCommandBloc({@required this.lounge, @required this.lobbyChannel});

  sendIRCCommand({@required String ircCommand, String args = ""}) async =>
      doAsyncOperation(() async => await lounge.sendChatMessageRequest(
          lobbyChannel.remoteId, "$ircCommand $args"));

  @override
  void dispose() {
    super.dispose();
  }
}
