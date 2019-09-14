import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/widgets/irc_network_server_preferences_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_user_preferences_widget.dart';

import 'form_widgets.dart';

class IRCNetworkPreferencesWidget extends StatefulWidget {
  final IRCNetworkPreferences preferences;

  IRCNetworkPreferencesWidget(this.preferences);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkPreferencesWidgetState(preferences);
}

class IRCNetworkPreferencesWidgetState
    extends State<IRCNetworkPreferencesWidget> {
  final IRCNetworkPreferences preferences;

  TextEditingController _channelsController;

  IRCNetworkPreferencesWidgetState(this.preferences) {
    _channelsController =
        TextEditingController(text: preferences.channelsString);
  }

  void _fillPreferencesFromUI() {
    preferences.notLobbyChannelsString = _channelsController.text;
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        IRCNetworkServerPreferencesWidget(preferences.networkConnectionPreferences.serverPreferences),
        IRCNetworkUserPreferencesWidget(preferences.networkConnectionPreferences.userPreferences),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.channels'),
            Icons.list,
            _channelsController,
            (newValue) => _fillPreferencesFromUI()),

      ],
    );
  }
}
