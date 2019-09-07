import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';


class IRCConnectionBloc extends AsyncOperationBloc {
  LoungeService service;

  IRCConnectionBloc(this.service);

  IRCConnectionInfo connection = IRCConnectionInfo(
      networkPreferences: NetworkPreferences(),
      userPreferences: UserPreferences());

  sendNewNetworkRequest() async {
    onOperationStarted();
    var result = await service.sendNewNetworkRequest(connection);
    onOperationFinished();
    return result;
  }

  @override
  void dispose() {

  }
}
