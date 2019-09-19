import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';


class IRCNetworkUserPreferencesFormWidget extends StatefulWidget {
  final IRCNetworkUserPreferences startValues;

  IRCNetworkUserPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkUserPreferencesFormState(startValues);
}

class IRCNetworkUserPreferencesFormState
    extends State<IRCNetworkUserPreferencesFormWidget> {
  final IRCNetworkUserPreferences startValues;

  TextEditingController _nickController;
  TextEditingController _userNameController;
  TextEditingController _realNameController;
  TextEditingController _passwordController;

  IRCNetworkUserPreferencesFormState(this.startValues) {
    _nickController = TextEditingController(text: startValues.nickname);
    _userNameController = TextEditingController(text: startValues.username);
    _realNameController = TextEditingController(text: startValues.realName);
    _passwordController = TextEditingController(text: startValues.password);
  }

  @override
  void dispose() {
    super.dispose();
    _nickController.dispose();
    _userNameController.dispose();
    _realNameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formBloc = Provider.of<IRCNetworkUserPreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('irc_connection.user_prefs.title')),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.nick_label'),
            appLocalizations.tr('irc_connection.user_prefs.nick_hint'),
            Icons.account_circle,
            formBloc.nickFieldBloc, _nickController),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.password_label'),
            appLocalizations.tr('irc_connection.user_prefs.password_hint'),
            Icons.lock,
            formBloc.passwordFieldBloc, _passwordController),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.real_name_label'),
            appLocalizations.tr('irc_connection.user_prefs.real_name_hint'),
            Icons.account_circle,
            formBloc.realNameFieldBloc, _realNameController),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.user_name_hint'),
            appLocalizations.tr('irc_connection.user_prefs.user_name_label'),
            Icons.account_circle,
            formBloc.realNameFieldBloc,  _userNameController),
      ],
    );
  }
}
