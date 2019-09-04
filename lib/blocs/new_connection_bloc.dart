import 'package:flutter_appirc/blocs/bloc.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/connection_model.dart';

///
/// TODO: make for flutter friendly (streams)
class NewConnectionBloc extends BlocBase {
  ChatBloc chatBloc;

  NewConnectionBloc(this.chatBloc);

  ChannelsConnection connection = ChannelsConnection(
      networkPreferences: NetworkPreferences(),
      userPreferences: UserPreferences());

  void addConnectionToChat() {
    chatBloc.connect(connection);
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
