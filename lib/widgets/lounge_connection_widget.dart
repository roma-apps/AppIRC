import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/provider.dart';

import 'form_widgets.dart';

class LoungePreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoungePreferencesConnectionFormState();
}

class LoungePreferencesConnectionFormState
    extends State<LoungePreferencesConnectionFormWidget> {
  final hostController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final NewLoungeConnectionBloc lounge =
        Provider.of<NewLoungeConnectionBloc>(context);

    hostController.text = lounge.newConnectionPreferences.host;
    return Column(
      children: <Widget>[
        formTitle(context,
            AppLocalizations.of(context).tr('lounge_connection.settings')),
        formTextRow(AppLocalizations.of(context).tr('lounge_connection.host'),
            hostController, (value) {
          lounge.newConnectionPreferences.host = value;
        }),
      ],
    );
  }
}
