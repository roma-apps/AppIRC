import 'package:flutter_appirc/blocs/bloc.dart';
import 'package:flutter_appirc/models/connection_model.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';

class ChatBloc extends BlocBase {
  TheLoungeService lounge;

  ChatBloc(this.lounge);

  @override
  void dispose() {
    // TODO: implement dispose
  }

  void connect(ChannelsConnection connection) =>
      lounge.sendCommand(connection.toLoungeRequest());
}
