import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/connection/lounge_connection_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

MyLogger _logger = MyLogger(
    logTag:
    "lounge_connection_preferences_form_widget.dart",
    enabled: true);

class LoungeConnectionPreferencesFormWidget extends StatefulWidget {
  final LoungeConnectionPreferences startValues;

  LoungeConnectionPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      LoungeConnectionPreferencesFormWidgetState(startValues);
}

class LoungeConnectionPreferencesFormWidgetState
    extends State<LoungeConnectionPreferencesFormWidget> {
  final LoungeConnectionPreferences startValues;
  TextEditingController _hostController;

  LoungeConnectionPreferencesFormWidgetState(this.startValues) {
    _logger.d(() => "create");
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
        Provider.of<LoungeConnectionPreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);

    _logger.d(() => "build");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(context,
            appLocalizations.tr('lounge.preferences.connection.title')),
        buildFormTextRow(
          context,
          loungePreferencesFormBloc.hostFieldBloc,
          _hostController,
          Icons.cloud,
          appLocalizations.tr('lounge.preferences.connection.field.host.label'),
          appLocalizations.tr('lounge.preferences.connection.field.host.hint'),
          textInputAction: TextInputAction.done,
        )
      ],
    );
  }
}
