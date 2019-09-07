import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_connection_bloc.dart';

import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'form_widgets.dart';


class UserPreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserPreferencesConnectionFormState();
}

class UserPreferencesConnectionFormState
    extends State<UserPreferencesConnectionFormWidget> {
  final nicknameController =
      TextEditingController(text: UserPreferences.defaultNick);
  final channelsController =
      TextEditingController(text: IRCConnectionInfo.defaultChannels);
  final passwordController = TextEditingController();
  final realNameController =
      TextEditingController(text: UserPreferences.defaultRealName);
  final userNameController =
      TextEditingController(text: UserPreferences.defaultUserName);

  @override
  Widget build(BuildContext context) {
    final IRCConnectionBloc ircConnectionBloc =
        Provider.of<IRCConnectionBloc>(context);

    fillPreferences(ircConnectionBloc);

    return Column(
      children: <Widget>[
        formTitle(context,
            AppLocalizations.of(context).tr('irc_connection.user_prefs.title')),
        formTextRow(
            AppLocalizations.of(context).tr('irc_connection.user_prefs.nick'),
            nicknameController,
            (value) => fillPreferences(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.password'),
            passwordController,
            (value) => fillPreferences(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.real_name'),
            realNameController,
            (value) => fillPreferences(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.user_name'),
            userNameController,
            (value) => fillPreferences(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.channels'),
            channelsController,
            (value) => fillPreferences(ircConnectionBloc))
      ],
    );
  }

  void fillPreferences(IRCConnectionBloc ircConnectionBloc) {
    final IRCConnectionBloc ircConnectionBloc =
        Provider.of<IRCConnectionBloc>(context);

    var connection = ircConnectionBloc.connection;
    var preferences = connection.userPreferences;
    preferences.password = passwordController.text;
    preferences.nickname = nicknameController.text;
    connection.channels = channelsController.text;
    preferences.realName = realNameController.text;
    preferences.username = userNameController.text;
  }
}


class NetworkPreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      NetworkPreferencesConnectionFormState();
}

class NetworkPreferencesConnectionFormState
    extends State<NetworkPreferencesConnectionFormWidget> {
  final nameController =
      TextEditingController(text: NetworkPreferences.defaultName);
  final serverController =
      TextEditingController(text: NetworkPreferences.defaultHost);
  final portController =
      TextEditingController(text: NetworkPreferences.defaultPort);
  bool tlsEnabled = NetworkPreferences.defaultUseTls;
  bool onlyTrustedCertificatesEnabled =
      NetworkPreferences.defaultUseOnlyTrustedCertificates;

  @override
  Widget build(BuildContext context) {
    final IRCConnectionBloc ircConnectionBloc =
        Provider.of<IRCConnectionBloc>(context);
    fillPreferences(ircConnectionBloc);
    return Column(
      children: <Widget>[
        formTitle(
            context,
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.title')),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.name'),
            nameController,
            (newValue) => fillPreferences(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.server_host'),
            serverController,
            (newValue) => fillPreferences(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.server_port'),
            portController,
            (newValue) => fillPreferences(ircConnectionBloc)),
        formBooleanRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.use_tls'),
            tlsEnabled, (newValue) {
          setState(() {
            tlsEnabled = newValue;
            fillPreferences(ircConnectionBloc);
          });
        }),
        formBooleanRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.trusted_only'),
            onlyTrustedCertificatesEnabled, (newValue) {
          setState(() {
            onlyTrustedCertificatesEnabled = newValue;
            fillPreferences(ircConnectionBloc);
          });
        })
      ],
    );
  }

  void fillPreferences(IRCConnectionBloc ircConnectionBloc) {
    var preferences = ircConnectionBloc.connection.networkPreferences;
    preferences.useOnlyTrustedCertificates = onlyTrustedCertificatesEnabled;
    preferences.useTls = tlsEnabled;
    preferences.serverPort = portController.text;
    preferences.serverHost = serverController.text;
    preferences.name = nameController.text;
  }
}
