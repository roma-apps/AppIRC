import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _joinIRCCommand = "/join";

class IRCNetworkChannelJoinBloc extends AsyncOperationBloc {
  final LoungeService _lounge;
  final IRCNetwork network;

  IRCNetworkChannelJoinBloc(this._lounge, this.network);

  // choose first channel from network.
  // TODO: check if not channel available
  int get remoteChannelId {
    return network.channels[0].remoteId;
  }

  sendJoinChannelRequest(String name, String password) async {
    onOperationStarted();
    if (password == null) {
      password = "";
    }
    var result = await _lounge.sendChatMessageRequest(
        remoteChannelId, "$_joinIRCCommand $name $password");
    onOperationFinished();

    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
