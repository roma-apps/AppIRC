import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class LoungeAuthPreferencesFormWidget extends StatefulWidget {
  final LoungeAuthPreferences _startPreferences;

  LoungeAuthPreferencesFormWidget(this._startPreferences);

  @override
  State<StatefulWidget> createState() =>
      LoungeAuthPreferencesFormWidgetState(_startPreferences);
}

class LoungeAuthPreferencesFormWidgetState
    extends State<LoungeAuthPreferencesFormWidget> {
  final LoungeAuthPreferences _startPreferences;
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  LoungeAuthPreferencesFormWidgetState(this._startPreferences) {
    _usernameController =
        TextEditingController(text: _startPreferences?.username);
    _passwordController =
        TextEditingController(text: _startPreferences?.password);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formBloc = Provider.of<LoungeAuthPreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(
            context: context,
            title: appLocalizations.tr('lounge.preferences.auth.title')),
        buildFormTextRow(
          context: context,
          bloc: formBloc.usernameFieldBloc,
          controller: _usernameController,
          icon: Icons.account_box,
          label: appLocalizations.tr('lounge.preferences.auth.field.username'
              '.label'),
          hint: appLocalizations.tr('lounge.preferences.auth.field.username'
              '.hint'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          nextBloc: formBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.passwordFieldBloc,
          controller: _passwordController,
          icon: Icons.lock,
          label: appLocalizations.tr('lounge.preferences.auth.field.password'
              '.label'),
          hint: appLocalizations.tr('lounge.preferences.auth.field.password'
              '.hint'),
          obscureText: true,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
        )
      ],
    );
  }
}
