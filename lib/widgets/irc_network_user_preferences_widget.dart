import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';


import 'form_widgets.dart';

class IRCNetworkUserPreferencesWidget extends StatefulWidget {
  final IRCNetworkUserPreferences preferences;

  IRCNetworkUserPreferencesWidget(this.preferences);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkUserPreferencesState(preferences);
}

class IRCNetworkUserPreferencesState
    extends State<IRCNetworkUserPreferencesWidget> {
  final IRCNetworkUserPreferences preferences;

  IRCNetworkUserPreferencesState(this.preferences) {
    _nicknameController = TextEditingController(text: preferences.nickname);
    _passwordController = TextEditingController(text: preferences.password);
    _realNameController = TextEditingController(text: preferences.realName);
    _userNameController = TextEditingController(text: preferences.username);
  }

  TextEditingController _nicknameController;
  TextEditingController _passwordController;
  TextEditingController _realNameController;
  TextEditingController _userNameController;

  @override
  Widget build(BuildContext context) {
    _fillPreferencesToUI();

    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('irc_connection.user_prefs.title')),
        buildFormTextRow(appLocalizations.tr('irc_connection.user_prefs.nick'),
            Icons.account_circle,
            _nicknameController, (value) => _fillPreferencesFromUI()),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.password'),
            Icons.lock,
            _passwordController,
            (value) => _fillPreferencesFromUI()),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.real_name'),
            Icons.account_circle,
            _realNameController,
            (value) => _fillPreferencesFromUI()),
        buildFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.user_name'),
            Icons.account_circle,
            _userNameController,
            (value) => _fillPreferencesFromUI()),
      ],
    );
  }

  void _fillPreferencesFromUI() {
    preferences.username = _userNameController.text;
    preferences.nickname = _nicknameController.text;
    preferences.realName = _realNameController.text;
  }

  void _fillPreferencesToUI() {
    _passwordController.text = preferences.password;
    _nicknameController.text = preferences.nickname;
    _realNameController.text = preferences.realName;
    _userNameController.text = preferences.username;
  }
}
