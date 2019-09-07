import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/channel_bloc.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _joinIRCCommand = "/join";


class JoinChannelBloc extends AsyncOperationBloc {
  LoungeService lounge;
  Network network;


  JoinChannelBloc(this.lounge, this.network);

  // choose first channel from network.
  // TODO: check if not channel available
  int get remoteChannelId {
    return network.channels[0].remoteId;
  }

  sendJoinChannelRequest(String name, String password) async {

    onOperationStarted();
    if(password == null) {
      password = "";
    }
    await lounge.sendChatMessageRequest(remoteChannelId, "$_joinIRCCommand $name $password");
    onOperationFinished();
  }

  @override
  void dispose() {

  }
}
