import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/host/lounge_host_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';

import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:logging/logging.dart';

var _logger = Logger("lounge_connection_preferences_form_widget.dart");

class LoungeHostPreferencesFormWidget extends StatefulWidget {
  final LoungeHostPreferencesFormBloc _hostPreferencesFormBloc;

  LoungeHostPreferencesFormWidget(this._hostPreferencesFormBloc);

  @override
  State<StatefulWidget> createState() => LoungeHostPreferencesFormWidgetState(
      _hostPreferencesFormBloc.extractData());
}

class LoungeHostPreferencesFormWidgetState
    extends State<LoungeHostPreferencesFormWidget> {
  TextEditingController _hostController;

  LoungeHostPreferencesFormWidgetState(
      LoungeHostPreferences loungeHostPreferences) {
    _hostController = TextEditingController(text: loungeHostPreferences.host);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      widget._hostPreferencesFormBloc.hostFieldBloc.valueStream
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
    var hostFormBloc = widget._hostPreferencesFormBloc;

    _logger.fine(() => "build");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(
          context: context,
          title: S.of(context).lounge_preferences_host_title,
        ),
        buildFormTextRow(
          context: context,
          textCapitalization: TextCapitalization.none,
          bloc: hostFormBloc.hostFieldBloc,
          controller: _hostController,
          icon: Icons.cloud,
          label: S.of(context).lounge_preferences_host_field_host_label,
          hint: S.of(context).lounge_preferences_host_field_host_hint,
          textInputAction: TextInputAction.done,
        )
      ],
    );
  }
}
