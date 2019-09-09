import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/helpers/provider.dart';

import 'form_widgets.dart';

class IRCNetworkServerPreferencesWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      IRCNetworkServerPreferencesState();
}

class IRCNetworkServerPreferencesState
    extends State<IRCNetworkServerPreferencesWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _tlsEnabled;
  bool _onlyTrustedCertificatesEnabled;

  @override
  Widget build(BuildContext context) {
    final IRCNetworksNewConnectionBloc ircConnectionBloc =
        Provider.of<IRCNetworksNewConnectionBloc>(context);
    _fillPreferencesToUI(ircConnectionBloc);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context,
            appLocalizations
                .tr('irc_connection.network_prefs.title')),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.network_prefs.name'),
            _nameController,
            (newValue) => _fillPreferencesFromUI(ircConnectionBloc)),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.network_prefs.server_host'),
            _hostController,
            (newValue) => _fillPreferencesFromUI(ircConnectionBloc)),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.network_prefs.server_port'),
            _portController,
            (newValue) => _fillPreferencesFromUI(ircConnectionBloc)),
        buildFormBooleanRow(
            appLocalizations
                .tr('irc_connection.network_prefs.use_tls'),
            _tlsEnabled, (newValue) {
          setState(() {
            _tlsEnabled = newValue;
            _fillPreferencesFromUI(ircConnectionBloc);
          });
        }),
        buildFormBooleanRow(
            appLocalizations
                .tr('irc_connection.network_prefs.trusted_only'),
            _onlyTrustedCertificatesEnabled, (newValue) {
          setState(() {
            _onlyTrustedCertificatesEnabled = newValue;
            _fillPreferencesFromUI(ircConnectionBloc);
          });
        })
      ],
    );
  }

  void _fillPreferencesFromUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    ircNetworksNewConnectionBloc
        .setNewNetworkPreferences(IRCNetworkServerPreferences(
      serverPort: _portController.text,
      useTls: _tlsEnabled,
      useOnlyTrustedCertificates: _onlyTrustedCertificatesEnabled,
      name: _nameController.text,
      serverHost: _hostController.text,
    ));
  }

  void _fillPreferencesToUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    var preferences =
        ircNetworksNewConnectionBloc.newConnectionPreferences.serverPreferences;
    _onlyTrustedCertificatesEnabled = preferences.useOnlyTrustedCertificates;
    _tlsEnabled = preferences.useTls;
    _portController.text = preferences.serverPort;
    _hostController.text = preferences.serverHost;
    _nameController.text = preferences.name;
  }
}
