import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkBloc extends Providable {

  final ChatBackendService backendService;
  final IRCNetwork network;


  NetworkBloc(this.backendService, this.network);

  @override
  void dispose() {
    // TODO: implement dispose
  }

  Future<bool> joinChannel(String channelName, String password) async {
    return await backendService.sendJoinChannelMessageRequest(
        network.lobbyChannel,
        JoinIRCCommand(channelName: channelName, channelPassword: password));
  }


}