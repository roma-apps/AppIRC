import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkUserPreferencesFormWidget extends StatefulWidget {
  final ChatNetworkUserPreferences startValues;

  NetworkUserPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      NetworkUserPreferencesFormState(startValues);
}

class NetworkUserPreferencesFormState
    extends State<NetworkUserPreferencesFormWidget> {
  final ChatNetworkUserPreferences startValues;

  TextEditingController _nickController;
  TextEditingController _userNameController;
  TextEditingController _realNameController;
  TextEditingController _passwordController;
  TextEditingController _commandsController;

  NetworkUserPreferencesFormState(this.startValues) {
    _nickController = TextEditingController(text: startValues.nickname);
    _userNameController = TextEditingController(text: startValues.username);
    _realNameController = TextEditingController(text: startValues.realName);
    _passwordController = TextEditingController(text: startValues.password);
    _commandsController = TextEditingController(text: startValues.commands);
  }

  @override
  void dispose() {
    super.dispose();
    _nickController.dispose();
    _userNameController.dispose();
    _realNameController.dispose();
    _passwordController.dispose();
    _commandsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formBloc = Provider.of<NetworkUserPreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('irc.connection.preferences.user.title')),
        buildFormTextRow(
          context,
          formBloc.nickFieldBloc,
          _nickController,
          Icons.account_circle,
          appLocalizations.tr('irc.connection.preferences.user.field.nick.label'),
          appLocalizations.tr('irc.connection.preferences.user.field.nick.hint'),
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
          context,
          formBloc.passwordFieldBloc,
          _passwordController,
          Icons.lock,
          appLocalizations.tr('irc.connection.preferences.user.field.password.label'),
          appLocalizations.tr('irc.connection.preferences.user.field.password.hint'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          obscureText: true,
          nextBloc: formBloc.realNameFieldBloc,
        ),
        buildFormTextRow(
          context,
          formBloc.realNameFieldBloc,
          _realNameController,
          Icons.account_circle,
          appLocalizations.tr('irc.connection.preferences.user.field.real_name.label'),
          appLocalizations.tr('irc.connection.preferences.user.field.real_name.hint'),
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.userNameFieldBloc,
        ),
        buildFormTextRow(
          context,
          formBloc.userNameFieldBloc,
          _userNameController,
          Icons.account_circle,
          appLocalizations.tr('irc.connection.preferences.user.field.user_name.label'),
          appLocalizations.tr('irc.connection.preferences.user.field.user_name.hint'),
          textInputAction: TextInputAction.done,
        ),
        buildFormTextRow(
          context,
          formBloc.commandsFieldBloc,
          _commandsController,
          Icons.settings,
          appLocalizations.tr('irc.connection.preferences.user.field.commands.label'),
          appLocalizations.tr('irc.connection.preferences.user.field.commands.hint'),
          textInputAction: TextInputAction.newline,
          minLines: 1,
          maxLines: 4,
        ),
      ],
    );
  }
}
