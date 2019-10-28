import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/connection/lounge_connection_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

MyLogger _logger = MyLogger(
    logTag: "lounge_connection_preferences_form_widget.dart", enabled: true);

class LoungeConnectionPreferencesFormWidget extends StatefulWidget {
  final LoungeConnectionPreferences _startPreferences;

  LoungeConnectionPreferencesFormWidget(this._startPreferences);

  @override
  State<StatefulWidget> createState() =>
      LoungeConnectionPreferencesFormWidgetState(_startPreferences);
}

class LoungeConnectionPreferencesFormWidgetState
    extends State<LoungeConnectionPreferencesFormWidget> {
  final LoungeConnectionPreferences _startPreferences;
  TextEditingController _hostController;

  LoungeConnectionPreferencesFormWidgetState(this._startPreferences) {
    _logger.d(() => "create");
    _hostController = TextEditingController(text: _startPreferences.host);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      var loungePreferencesFormBloc =
          Provider.of<LoungeConnectionPreferencesFormBloc>(context);

      // todo: remove. Need only for test
      loungePreferencesFormBloc.hostFieldBloc.valueStream
          .distinct()
          .listen((String newHost) {
        if (_hostController.text != newHost) {
          _hostController.text = newHost;
        }
      });
    });
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
        buildFormTitle(
            context: context,
            title: appLocalizations.tr('lounge.preferences.connection.title')),
        buildFormTextRow(
          context: context,
          bloc: loungePreferencesFormBloc.hostFieldBloc,
          controller: _hostController,
          icon: Icons.cloud,
          label: appLocalizations.tr('lounge.preferences.connection.field.host'
              '.label'),
          hint: appLocalizations.tr('lounge.preferences.connection.field.host'
              '.hint'),
          textInputAction: TextInputAction.done,
        )
      ],
    );
  }
}
