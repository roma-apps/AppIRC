import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class LoungeAuthPreferencesFormWidget extends StatefulWidget {
  final String titleText;

  LoungeAuthPreferencesFormWidget({
    @required this.titleText,
  });

  @override
  State<StatefulWidget> createState() => LoungeAuthPreferencesFormWidgetState();
}

class LoungeAuthPreferencesFormWidgetState
    extends State<LoungeAuthPreferencesFormWidget> {
  // todo: rework with bloc
  TextEditingController _usernameController;
  TextEditingController _passwordController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var loungeAuthPreferencesFormBloc =
        Provider.of<LoungeAuthPreferencesFormBloc>(
      context,
      listen: false,
    );

    var startPreferences = loungeAuthPreferencesFormBloc.extractData();

    _usernameController = TextEditingController(
      text: startPreferences?.username,
    );
    _passwordController = TextEditingController(
      text: startPreferences?.password,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loungeAuthPreferencesFormBloc =
        Provider.of<LoungeAuthPreferencesFormBloc>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildFormTitle(
          context: context,
          title: widget.titleText,
        ),
        buildFormTextRow(
          context: context,
          bloc: loungeAuthPreferencesFormBloc.usernameFieldBloc,
          controller: _usernameController,
          icon: Icons.account_box,
          label: S.of(context).lounge_preferences_auth_field_username_label,
          hint: S.of(context).lounge_preferences_auth_field_username_hint,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          nextBloc: loungeAuthPreferencesFormBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: loungeAuthPreferencesFormBloc.passwordFieldBloc,
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
