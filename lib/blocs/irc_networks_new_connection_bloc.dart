import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/models/irc_networks_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworksNewConnectionBloc extends AsyncOperationBloc {
  final LoungeService loungeService;

  final IRCNetworksPreferencesBloc preferencesBloc;

  final IRCNetworkPreferences newConnectionPreferences;

  IRCNetworksNewConnectionBloc(
      {@required this.loungeService,
      @required this.preferencesBloc,
      @required this.newConnectionPreferences});

  sendNewNetworkRequest() async {
    onOperationStarted();
    var result =
        await loungeService.sendNewNetworkRequest(newConnectionPreferences);
    var networksPreferences = preferencesBloc.preferenceOrNull;
    if (networksPreferences == null) {
      networksPreferences = IRCNetworksPreferences([newConnectionPreferences]);
    }
    await preferencesBloc.setNewPreferenceValue(networksPreferences);
    onOperationFinished();
    return result;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setNewNetworkPreferences(IRCNetworkServerPreferences serverPreferences) {
    newConnectionPreferences.serverPreferences = serverPreferences;
  }

  void setNewUserPreferences(IRCNetworkUserPreferences userPreferences) {
    newConnectionPreferences.userPreferences = userPreferences;
  }
}
