import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';


import 'form_widgets.dart';

class IRCNetworkServerPreferencesWidget extends StatefulWidget {
  final IRCNetworkServerPreferences preferences;

  IRCNetworkServerPreferencesWidget(this.preferences);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkServerPreferencesState(preferences);
}

class IRCNetworkServerPreferencesState
    extends State<IRCNetworkServerPreferencesWidget> {
  final IRCNetworkServerPreferences preferences;

  IRCNetworkServerPreferencesState(this.preferences) {
    _nameController = TextEditingController(text: preferences.name);
    _hostController = TextEditingController(text: preferences.serverHost);
    _portController = TextEditingController(text: preferences.serverPort);

    _onlyTrustedCertificatesEnabled = preferences.useOnlyTrustedCertificates;
    _tlsEnabled = preferences.useTls;
  }

  TextEditingController _nameController;
  TextEditingController _hostController;
  TextEditingController _portController;
  bool _tlsEnabled;
  bool _onlyTrustedCertificatesEnabled;

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('irc_connection.network_prefs.title')),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.network_prefs.name'),
            Icons.account_circle,
            _nameController,
            (newValue) => _fillPreferencesFromUI()),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.network_prefs.server_host'),
            Icons.cloud,
            _hostController,
            (newValue) => _fillPreferencesFromUI()),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.network_prefs.server_port'),
            Icons.cloud,
            _portController,
            (newValue) => _fillPreferencesFromUI()),
        buildFormBooleanRow(
            appLocalizations.tr('irc_connection.network_prefs.use_tls'),
            _tlsEnabled, (newValue) {
          setState(() {
            _tlsEnabled = newValue;
            _fillPreferencesFromUI();
          });
        }),
        buildFormBooleanRow(
            appLocalizations.tr('irc_connection.network_prefs.trusted_only'),
            _onlyTrustedCertificatesEnabled, (newValue) {
          setState(() {
            _onlyTrustedCertificatesEnabled = newValue;
            _fillPreferencesFromUI();
          });
        })
      ],
    );
  }

  void _fillPreferencesFromUI() {
    preferences.serverPort = _portController.text;
    preferences.useTls = _tlsEnabled;
    preferences.useOnlyTrustedCertificates = _onlyTrustedCertificatesEnabled;
    preferences.name = _nameController.text;
    preferences.serverHost = _hostController.text;
  }
}
