import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_server_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkServerPreferencesFormWidget extends StatefulWidget {

  final IRCNetworkServerPreferences startValues;

  IRCNetworkServerPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkServerPreferencesFormWidgetState(startValues);
}

class IRCNetworkServerPreferencesFormWidgetState
    extends State<IRCNetworkServerPreferencesFormWidget> {

  final IRCNetworkServerPreferences startValues;

  TextEditingController _hostController;
  TextEditingController _portController;
  TextEditingController _nameController;

  IRCNetworkServerPreferencesFormWidgetState(this.startValues) {
    _hostController =
        TextEditingController(text: startValues.serverHost);
    _portController =
        TextEditingController(text: startValues.serverPort);
    _nameController =
        TextEditingController(text: startValues.name);
  }

  @override
  void dispose() {
    super.dispose();
    _hostController.dispose();
    _portController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    var formBloc = Provider.of<IRCNetworkServerPreferencesFormBloc>(context);

    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('irc_connection.network_prefs.title')),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.network_prefs.name_label'),
            appLocalizations.tr('irc_connection.network_prefs.name_hint'),
            Icons.account_circle,
            formBloc.nameFieldBloc, _nameController),
        buildFormTextRow(
            appLocalizations
                .tr('irc_connection.network_prefs.server_host_label'),
            appLocalizations
                .tr('irc_connection.network_prefs.server_host_hint'),
            Icons.cloud,
            formBloc.hostFieldBloc, _hostController),
        buildFormTextRow(
            appLocalizations
                .tr('irc_connection.network_prefs.server_port_label'),
            appLocalizations
                .tr('irc_connection.network_prefs.server_port_hint'),
            Icons.cloud,
            formBloc.portFieldBloc, _portController),
        buildFormBooleanRow(
            appLocalizations.tr('irc_connection.network_prefs.use_tls'),
            formBloc.tlsFieldBloc),
        buildFormBooleanRow(
            appLocalizations.tr('irc_connection.network_prefs.trusted_only'),
            formBloc.trustedFieldBloc)
      ],
    );
  }
}
