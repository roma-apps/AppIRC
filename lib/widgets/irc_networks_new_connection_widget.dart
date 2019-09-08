import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/provider.dart';

import 'form_widgets.dart';

class UserPreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => UserPreferencesConnectionFormState();
}

class UserPreferencesConnectionFormState
    extends State<UserPreferencesConnectionFormWidget> {
  final nicknameController = TextEditingController();
  final channelsController = TextEditingController();
  final passwordController = TextEditingController();
  final realNameController = TextEditingController();
  final userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc =
        Provider.of<IRCNetworksNewConnectionBloc>(context);

    fillPreferencesToUI(ircNetworksNewConnectionBloc);

    return Column(
      children: <Widget>[
        formTitle(context,
            AppLocalizations.of(context).tr('irc_connection.user_prefs.title')),
        formTextRow(
            AppLocalizations.of(context).tr('irc_connection.user_prefs.nick'),
            nicknameController,
            (value) => fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.password'),
            passwordController,
            (value) => fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.real_name'),
            realNameController,
            (value) => fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.user_name'),
            userNameController,
            (value) => fillPreferencesFromUI(ircNetworksNewConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.user_prefs.channels'),
            channelsController,
            (value) => fillPreferencesFromUI(ircNetworksNewConnectionBloc))
      ],
    );
  }

  void fillPreferencesFromUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    var connection = ircNetworksNewConnectionBloc.newConnectionPreferences;
    var preferences = connection.userPreferences;
    preferences.password = passwordController.text;
    preferences.nickname = nicknameController.text;
    connection.channels = channelsController.text.split(" ");
    preferences.realName = realNameController.text;
    preferences.username = userNameController.text;
  }

  void fillPreferencesToUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    var connection = ircNetworksNewConnectionBloc.newConnectionPreferences;
    var preferences = connection.userPreferences;
    passwordController.text = preferences.password;
    nicknameController.text = preferences.nickname;
    channelsController.text = connection.channels.join(" ");
    realNameController.text = preferences.realName;
    userNameController.text = preferences.username;
  }
}

class NetworkPreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      NetworkPreferencesConnectionFormState();
}

class NetworkPreferencesConnectionFormState
    extends State<NetworkPreferencesConnectionFormWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController serverController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  bool tlsEnabled;
  bool onlyTrustedCertificatesEnabled;

  @override
  Widget build(BuildContext context) {
    final IRCNetworksNewConnectionBloc ircConnectionBloc =
        Provider.of<IRCNetworksNewConnectionBloc>(context);
    fillPreferencesToUI(ircConnectionBloc);
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
            (newValue) => fillPreferencesFromUI(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.server_host'),
            serverController,
            (newValue) => fillPreferencesFromUI(ircConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.server_port'),
            portController,
            (newValue) => fillPreferencesFromUI(ircConnectionBloc)),
        formBooleanRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.use_tls'),
            tlsEnabled, (newValue) {
          setState(() {
            tlsEnabled = newValue;
            fillPreferencesFromUI(ircConnectionBloc);
          });
        }),
        formBooleanRow(
            AppLocalizations.of(context)
                .tr('irc_connection.network_prefs.trusted_only'),
            onlyTrustedCertificatesEnabled, (newValue) {
          setState(() {
            onlyTrustedCertificatesEnabled = newValue;
            fillPreferencesFromUI(ircConnectionBloc);
          });
        })
      ],
    );
  }

  void fillPreferencesFromUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    var preferences = ircNetworksNewConnectionBloc
        .newConnectionPreferences.networkPreferences;
    preferences.useOnlyTrustedCertificates = onlyTrustedCertificatesEnabled;
    preferences.useTls = tlsEnabled;
    preferences.serverPort = portController.text;
    preferences.serverHost = serverController.text;
    preferences.name = nameController.text;
  }

  void fillPreferencesToUI(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc) {
    var preferences = ircNetworksNewConnectionBloc
        .newConnectionPreferences.networkPreferences;
    onlyTrustedCertificatesEnabled = preferences.useOnlyTrustedCertificates;
    tlsEnabled = preferences.useTls;
    portController.text = preferences.serverPort;
    serverController.text = preferences.serverHost;
    nameController.text = preferences.name;
  }
}
