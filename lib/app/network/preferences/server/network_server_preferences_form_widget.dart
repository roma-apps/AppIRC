import 'package:flutter/material.dart' show Icons, TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/form/field/boolean/form_boolean_field_widget.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class NetworkServerPreferencesFormWidget extends StatefulWidget {
  final NetworkServerPreferences startValues;

  NetworkServerPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      NetworkServerPreferencesFormWidgetState(startValues);
}

class NetworkServerPreferencesFormWidgetState
    extends State<NetworkServerPreferencesFormWidget> {
  final NetworkServerPreferences startValues;

  TextEditingController _hostController;
  TextEditingController _portController;
  TextEditingController _nameController;

  NetworkServerPreferencesFormWidgetState(this.startValues) {
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
    var formBloc = Provider.of<NetworkServerPreferencesFormBloc>(context);

    return Column(
      children: <Widget>[
        buildFormTitle(
          context: context,
          title: S.of(context).irc_connection_preferences_server_title,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.nameFieldBloc,
          controller: _nameController,
          icon: Icons.account_circle,
          label:
              S.of(context).irc_connection_preferences_server_field_name_label,
          hint: S.of(context).irc_connection_preferences_server_field_name_hint,
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.hostFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.hostFieldBloc,
          controller: _hostController,
          icon: Icons.cloud,
          label:
              S.of(context).irc_connection_preferences_server_field_host_label,
          hint: S.of(context).irc_connection_preferences_server_field_host_hint,
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.portFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.portFieldBloc,
          controller: _portController,
          icon: Icons.cloud,
          label:
              S.of(context).irc_connection_preferences_server_field_port_label,
          hint: S.of(context).irc_connection_preferences_server_field_port_hint,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.number,
        ),
        buildFormBooleanRow(
          context: context,
          title: S
              .of(context)
              .irc_connection_preferences_server_field_use_tls_label,
          bloc: formBloc.tlsFieldBloc,
        ),
        buildFormBooleanRow(
          context: context,
          title: S
              .of(context)
              .irc_connection_preferences_server_field_trusted_only_label,
          bloc: formBloc.trustedFieldBloc,
        )
      ],
    );
  }
}
