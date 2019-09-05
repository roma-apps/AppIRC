import 'package:flutter_appirc/blocs/channel_bloc.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';

const String _joinIRCCommand = "/join";

///
/// TODO: make for flutter friendly (streams)
class JoinChannelBloc extends Providable {
  TheLoungeService lounge;
  Network network;


  JoinChannelBloc(this.lounge, this.network);

  // choose first channel from network.
  // TODO: check if not channel available
  int get remoteChannelId {
    return network.channels[0].remoteId;
  }

  void joinChannel(String name, String password) {

    if(password == null) {
      password = "";
    }
    lounge.sendChatMessage(remoteChannelId, "$_joinIRCCommand $name $password");
  }

  @override
  void dispose() {

  }
}
