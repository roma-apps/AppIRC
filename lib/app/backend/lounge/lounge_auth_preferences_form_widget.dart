import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_connection_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class LoungeAuthPreferencesFormWidget extends StatefulWidget {
  final LoungeAuthPreferences startValues;

  LoungeAuthPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      LoungeAuthPreferencesFormWidgetState(startValues);
}

class LoungeAuthPreferencesFormWidgetState
    extends State<LoungeAuthPreferencesFormWidget> {
  final LoungeAuthPreferences startValues;
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  LoungeAuthPreferencesFormWidgetState(this.startValues) {
    _usernameController = TextEditingController(text: startValues?.username);
    _passwordController = TextEditingController(text: startValues?.password);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loungePreferencesFormBloc =
        Provider.of<LoungeAuthPreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('lounge.preferences.auth.title')),
        buildFormTextRow(
            context,
            appLocalizations.tr('lounge.preferences.auth.username.label'),
            appLocalizations.tr('lounge.preferences.auth.username.hint'),
            Icons.account_box,
            loungePreferencesFormBloc.usernameFieldBloc,
            _usernameController),
        buildFormTextRow(
            context,
            appLocalizations.tr('lounge.preferences.auth.password.label'),
            appLocalizations.tr('lounge.preferences.auth.password.hint'),
            Icons.lock,
            loungePreferencesFormBloc.passwordFieldBloc,
            _passwordController)
      ],
    );
  }
}
