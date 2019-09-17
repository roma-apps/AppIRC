import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_server_preferences_form_widget.dart';
import 'package:flutter_appirc/app/networks/irc_network_user_preferences_widget_form.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

import 'irc_network_preferences_form_bloc.dart';

class IRCNetworkPreferencesFormWidget extends StatefulWidget {
  final IRCNetworkPreferences startValues;

  IRCNetworkPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkPreferencesFormWidgetState(startValues);
}

class IRCNetworkPreferencesFormWidgetState
    extends State<IRCNetworkPreferencesFormWidget> {
  final IRCNetworkPreferences startValues;

  TextEditingController _channelsController;

  IRCNetworkPreferencesFormWidgetState(this.startValues) {
    _channelsController =
        TextEditingController(text: startValues.channelsString);
  }

  @override
  void dispose() {
    super.dispose();
    _channelsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IRCNetworkPreferencesFormBloc formBloc = Provider.of<IRCNetworkPreferencesFormBloc>(context);

    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Provider(
            bloc: formBloc.serverFormBloc,
            child: IRCNetworkServerPreferencesFormWidget(
                startValues.networkConnectionPreferences.serverPreferences)),
        Provider(
            bloc: formBloc.userFormBloc,
            child: IRCNetworkUserPreferencesFormWidget(
                startValues.networkConnectionPreferences.userPreferences)),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.channels_title'),
            appLocalizations.tr('irc_connection.channels_hint'),
            Icons.list,
            formBloc.channelsFieldBloc,
            _channelsController),
      ],
    );
  }
}
