import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/app/networks/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';

import 'package:flutter_appirc/lounge/lounge_service.dart';

class IRCNetworksNewConnectionBloc extends AsyncOperationBloc {
  final LoungeService loungeService;

  final IRCNetworksPreferencesBloc preferencesBloc;

  final IRCNetworkPreferences newConnectionPreferences;

  IRCNetworksNewConnectionBloc(
      {@required this.loungeService,
      @required this.preferencesBloc,
      @required this.newConnectionPreferences});

  sendNewNetworkRequest() async => doAsyncOperation(() async {
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
        return await loungeService
            .sendNewNetworkRequest(newConnectionPreferences);
      });

  @override
  void dispose() {
    super.dispose();
  }
}

class ServerNameNotUniqueException implements Exception {}
