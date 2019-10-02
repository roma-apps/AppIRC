import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class LoungePreferencesFormWidget extends StatefulWidget {
  final LoungeConnectionPreferences startValues;

  LoungePreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      LoungePreferencesFormWidgetState(startValues);
}

class LoungePreferencesFormWidgetState
    extends State<LoungePreferencesFormWidget> {
  final LoungeConnectionPreferences startValues;
  TextEditingController _hostController;

  LoungePreferencesFormWidgetState(this.startValues) {
    _hostController = TextEditingController(text: startValues.host);
  }

  @override
  void dispose() {
    super.dispose();
    _hostController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loungePreferencesFormBloc =
        Provider.of<LoungePreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('lounge.connection.settings')),
        buildFormTextRow(
            context,
            appLocalizations.tr('lounge.connection.host_label'),
            appLocalizations.tr('lounge.connection.host_hint'),
            Icons.cloud,
            loungePreferencesFormBloc.hostFieldBloc,
            _hostController)
      ],
    );
  }
}
