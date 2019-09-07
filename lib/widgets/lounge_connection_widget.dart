
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/lounge_connection_bloc.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

import 'form_widgets.dart';

class LoungePreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoungePreferencesConnectionFormState();
}

class LoungePreferencesConnectionFormState
    extends State<LoungePreferencesConnectionFormWidget> {
  final hostController =
  TextEditingController(text: LoungeService.defaultLoungeHost);

  @override
  Widget build(BuildContext context) {
    final LoungeConnectionBloc lounge = Provider.of<LoungeConnectionBloc>(context);

    return Column(
      children: <Widget>[
        formTitle(context,
            AppLocalizations.of(context).tr('lounge_connection.settings')),
        formTextRow(
            AppLocalizations.of(context).tr('lounge_connection.host'),
            hostController, (value) {
          lounge.host = value;
        }),
      ],
    );
  }
}