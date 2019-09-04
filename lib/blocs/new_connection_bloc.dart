import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';

///
/// TODO: make for flutter friendly (streams)
class NewConnectionBloc extends Providable {
  ChatBloc chatBloc;

  NewConnectionBloc(this.chatBloc);

  ChannelsConnectionInfo connection = ChannelsConnectionInfo(
      networkPreferences: NetworkPreferences(),
      userPreferences: UserPreferences());

  void addConnectionToChat() {
    chatBloc.connect(connection);
  }

  @override
  void dispose() {

  }
}
