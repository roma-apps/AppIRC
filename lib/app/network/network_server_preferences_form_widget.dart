import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_server_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

class ChatNetworkServerPreferencesFormWidget extends StatefulWidget {
  final ChatNetworkServerPreferences startValues;

  ChatNetworkServerPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      ChatNetworkServerPreferencesFormWidgetState(startValues);
}

class ChatNetworkServerPreferencesFormWidgetState
    extends State<ChatNetworkServerPreferencesFormWidget> {
  final ChatNetworkServerPreferences startValues;

  TextEditingController _hostController;
  TextEditingController _portController;
  TextEditingController _nameController;

  ChatNetworkServerPreferencesFormWidgetState(this.startValues) {
    _hostController = TextEditingController(text: startValues.serverHost);
    _portController = TextEditingController(text: startValues.serverPort);
    _nameController = TextEditingController(text: startValues.name);
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
    var formBloc = Provider.of<NetworkServerPreferencesFormBloc>(context);

    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('irc_connection.network_prefs.title')),
        buildFormTextRow(
          context,
          formBloc.nameFieldBloc,
          _nameController,
          Icons.account_circle,
          appLocalizations.tr('irc_connection.network_prefs.name_label'),
          appLocalizations.tr('irc_connection.network_prefs.name_hint'),
          textInputAction: TextInputAction.next,
          nextBloc:   formBloc.hostFieldBloc,
        ),
        buildFormTextRow(
          context,
          formBloc.hostFieldBloc,
          _hostController,
          Icons.cloud,
          appLocalizations.tr('irc_connection.network_prefs.server_host_label'),
          appLocalizations.tr('irc_connection.network_prefs.server_host_hint'),
          textInputAction: TextInputAction.next,
          nextBloc:   formBloc.portFieldBloc,
        ),
        buildFormTextRow(
            context,
            formBloc.portFieldBloc,
            _portController,
            Icons.cloud,
            appLocalizations
                .tr('irc_connection.network_prefs.server_port_label'),
            appLocalizations
                .tr('irc_connection.network_prefs.server_port_hint'),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number),
        buildFormBooleanRow(
            context,
            appLocalizations.tr('irc_connection.network_prefs.use_tls'),
            formBloc.tlsFieldBloc),
        buildFormBooleanRow(
            context,
            appLocalizations.tr('irc_connection.network_prefs.trusted_only'),
            formBloc.trustedFieldBloc)
      ],
    );
  }
}
