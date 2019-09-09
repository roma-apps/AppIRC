import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/helpers/provider.dart';

import 'form_widgets.dart';

class IRCNetworkUserPreferencesWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IRCNetworkUserPreferencesState();
}

class IRCNetworkUserPreferencesState
    extends State<IRCNetworkUserPreferencesWidget> {
  final _nicknameController = TextEditingController();
  final _channelsController = TextEditingController();
  final _passwordController = TextEditingController();
  final _realNameController = TextEditingController();
  final _userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc =
        Provider.of<IRCNetworksNewConnectionBloc>(context);

    _fillPreferencesToUI(ircNetworksNewConnectionBloc);

    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(context,
            appLocalizations.tr('irc_connection.user_prefs.title')),
        buidFormTextRow(
            appLocalizations.tr('irc_connection.user_prefs.nick'),
            _nicknameController,
            (value) => _fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.user_prefs.password'),
            _passwordController,
            (value) => _fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.user_prefs.real_name'),
            _realNameController,
            (value) => _fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.user_prefs.user_name'),
            _userNameController,
            (value) => _fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        buidFormTextRow(
            appLocalizations
                .tr('irc_connection.user_prefs.channels'),
            _channelsController,
            (value) => _fillPreferencesFromUI(ircNetworksNewConnectionBloc))
      ],
    );
  }

  void _fillPreferencesFromUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {

    ircNetworksNewConnectionBloc
        .setNewUserPreferences(IRCNetworkUserPreferences(
      username: _userNameController.text,
      nickname: _nicknameController.text,
      realName: _realNameController.text,
      channels: _channelsController.text
          .split(IRCNetworkUserPreferences.channelsSeparator),
    ));
  }

  void _fillPreferencesToUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    var connection = ircNetworksNewConnectionBloc.newConnectionPreferences;
    var preferences = connection.userPreferences;
    _passwordController.text = preferences.password;
    _nicknameController.text = preferences.nickname;
    _channelsController.text = preferences.channelsString;
    _realNameController.text = preferences.realName;
    _userNameController.text = preferences.username;
  }
}
