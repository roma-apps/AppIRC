import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeAuthPreferencesFormWidget extends StatefulWidget {
  final String titleText;
  final LoungeAuthPreferencesFormBloc formBloc;

  LoungeAuthPreferencesFormWidget(this.titleText, this.formBloc);

  @override
  State<StatefulWidget> createState() =>
      LoungeAuthPreferencesFormWidgetState(formBloc.extractData());
}

class LoungeAuthPreferencesFormWidgetState
    extends State<LoungeAuthPreferencesFormWidget> {
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  LoungeAuthPreferencesFormWidgetState(LoungeAuthPreferences startPreferences) {
    _usernameController =
        TextEditingController(text: startPreferences?.username);
    _passwordController =
        TextEditingController(text: startPreferences?.password);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(
          context: context,
          title: widget.titleText,
        ),
        buildFormTextRow(
          context: context,
          bloc: widget.formBloc.usernameFieldBloc,
          controller: _usernameController,
          icon: Icons.account_box,
          label: S.of(context).lounge_preferences_auth_field_username_label,
          hint: S.of(context).lounge_preferences_auth_field_username_hint,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          nextBloc: widget.formBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: widget.formBloc.passwordFieldBloc,
          controller: _passwordController,
          icon: Icons.lock,
          label: S.of(context).lounge_preferences_auth_field_password_label,
          hint: S.of(context).lounge_preferences_auth_field_password_hint,
          obscureText: true,
          textCapitalization: TextCapitalization.none,
          textInputAction: TextInputAction.done,
        )
      ],
    );
  }
}
