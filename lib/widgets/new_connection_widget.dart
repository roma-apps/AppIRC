import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/blocs/new_connection_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';

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
      TextEditingController(text: ChannelsConnectionInfo.defaultChannels);
  final passwordController = TextEditingController();
  final realNameController =
      TextEditingController(text: UserPreferences.defaultRealName);
  final userNameController =
      TextEditingController(text: UserPreferences.defaultUserName);

  @override
  Widget build(BuildContext context) {
    final NewConnectionBloc newConnectionBloc =
        Provider.of<NewConnectionBloc>(context);

    fillPreferences(newConnectionBloc);

    return Column(
      children: <Widget>[
        formTitle(context,
            AppLocalizations.of(context).tr('new_connection.user_prefs.title')),
        formTextRow(
            AppLocalizations.of(context).tr('new_connection.user_prefs.nick'),
            nicknameController,
            (value) => fillPreferences(newConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.user_prefs.password'),
            passwordController,
            (value) => fillPreferences(newConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.user_prefs.real_name'),
            realNameController,
            (value) => fillPreferences(newConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.user_prefs.user_name'),
            userNameController,
            (value) => fillPreferences(newConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.user_prefs.channels'),
            channelsController,
            (value) => fillPreferences(newConnectionBloc))
      ],
    );
  }

  void fillPreferences(NewConnectionBloc newConnectionBloc) {
    final NewConnectionBloc newConnectionBloc =
        Provider.of<NewConnectionBloc>(context);

    var connection = newConnectionBloc.connection;
    var preferences = connection.userPreferences;
    preferences.password = passwordController.text;
    preferences.nickname = nicknameController.text;
    connection.channels = channelsController.text;
    preferences.realName = realNameController.text;
    preferences.username = userNameController.text;
  }
}

class LoungePreferencesConnectionFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoungePreferencesConnectionFormState();
}

class LoungePreferencesConnectionFormState
    extends State<LoungePreferencesConnectionFormWidget> {
  final hostController =
      TextEditingController(text: TheLoungeService.defaultLoungeHost);

  @override
  Widget build(BuildContext context) {
    final TheLoungeService lounge = Provider.of<TheLoungeService>(context);

    return Column(
      children: <Widget>[
        formTitle(context,
            AppLocalizations.of(context).tr('new_connection.lounge.title')),
        formTextRow(
            AppLocalizations.of(context).tr('new_connection.lounge.host'),
            hostController, (value) {
          lounge.host = value;
        }),
      ],
    );
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
    final NewConnectionBloc newConnectionBloc =
        Provider.of<NewConnectionBloc>(context);
    fillPreferences(newConnectionBloc);
    return Column(
      children: <Widget>[
        formTitle(
            context,
            AppLocalizations.of(context)
                .tr('new_connection.network_prefs.title')),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.network_prefs.name'),
            nameController,
            (newValue) => fillPreferences(newConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.network_prefs.server_host'),
            serverController,
            (newValue) => fillPreferences(newConnectionBloc)),
        formTextRow(
            AppLocalizations.of(context)
                .tr('new_connection.network_prefs.server_port'),
            portController,
            (newValue) => fillPreferences(newConnectionBloc)),
        formBooleanRow(
            AppLocalizations.of(context)
                .tr('new_connection.network_prefs.use_tls'),
            tlsEnabled, (newValue) {
          setState(() {
            tlsEnabled = newValue;
            fillPreferences(newConnectionBloc);
          });
        }),
        formBooleanRow(
            AppLocalizations.of(context)
                .tr('new_connection.network_prefs.trusted_only'),
            onlyTrustedCertificatesEnabled, (newValue) {
          setState(() {
            onlyTrustedCertificatesEnabled = newValue;
            fillPreferences(newConnectionBloc);
          });
        })
      ],
    );
  }

  void fillPreferences(NewConnectionBloc newConnectionBloc) {
    var preferences = newConnectionBloc.connection.networkPreferences;
    preferences.useOnlyTrustedCertificates = onlyTrustedCertificatesEnabled;
    preferences.useTls = tlsEnabled;
    preferences.serverPort = portController.text;
    preferences.serverHost = serverController.text;
    preferences.name = nameController.text;
  }
}
