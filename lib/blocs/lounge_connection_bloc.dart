import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/provider.dart';

import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';



class LoungeConnectionBloc extends AsyncOperationBloc {
  LoungeService loungeService;

  String host = LoungeService.defaultLoungeHost;

  LoungeConnectionBloc(this.loungeService);

  IRCConnectionInfo connection = IRCConnectionInfo(
      networkPreferences: NetworkPreferences(),
      userPreferences: UserPreferences());

  connect() async {
    onOperationStarted();
    var result = await loungeService.connect(host);
    onOperationFinished();
    return result;
  }

  @override
  void dispose() {

  }
}
