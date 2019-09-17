import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

abstract class ChatBackendService extends Providable {
  sendJoinChannelMessageRequest(IRCNetworkChannel lobbyChannel, JoinIRCCommand joinIRCCommand) {}

}
