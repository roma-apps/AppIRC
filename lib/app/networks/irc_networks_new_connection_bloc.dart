import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/chat/chat_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';

class ChatNewNetworkBloc extends AsyncOperationBloc {
  final ChatBackendService backendService;
  final ChatBloc chatBloc;

  ChatNewNetworkBloc(
      this.backendService, this.chatBloc, IRCNetworkPreferences startValues);

  sendNewNetworkRequest() async => doAsyncOperation(() async {

    chatBloc.isNetworkWithNameExist();

        var networkListPreferences = preferencesBloc
            .getPreferenceOrValue(() => IRCNetworksListPreferences());

        var contains = networkListPreferences.networks.firstWhere(
                (network) =>
                    network.networkConnectionPreferences.name ==
                    newConnectionPreferences.networkConnectionPreferences.name,
                orElse: () => null) !=
            null;

        // name should be unique

        if (contains) {
          throw new ServerNameNotUniqueException();
        }
        return await backendService
            .sendNewNetworkRequest(newConnectionPreferences);
      });

  @override
  void dispose() {
    super.dispose();
  }
}

class ServerNameNotUniqueException implements Exception {}
