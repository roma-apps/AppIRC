import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_model.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/form/form_title_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkUserPreferencesFormWidget extends StatefulWidget {
  final NetworkUserPreferences startValues;

  NetworkUserPreferencesFormWidget(this.startValues);

  @override
  State<StatefulWidget> createState() =>
      NetworkUserPreferencesFormState(startValues);
}

class NetworkUserPreferencesFormState
    extends State<NetworkUserPreferencesFormWidget> {
  final NetworkUserPreferences startValues;

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
            context: context,
            title: appLocalizations.tr('irc.connection.preferences'
                '.user.title')),
        buildFormTextRow(
          context: context,
          bloc: formBloc.nickFieldBloc,
          controller: _nickController,
          icon: Icons.account_circle,
          label: appLocalizations
              .tr('irc.connection.preferences.user.field.nick.label'),
          hint: appLocalizations
              .tr('irc.connection.preferences.user.field.nick.hint'),
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.passwordFieldBloc,
          controller: _passwordController,
          icon: Icons.lock,
          label: appLocalizations
              .tr('irc.connection.preferences.user.field.password.label'),
          hint: appLocalizations
              .tr('irc.connection.preferences.user.field.password.hint'),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          obscureText: true,
          nextBloc: formBloc.realNameFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.realNameFieldBloc,
          controller: _realNameController,
          icon: Icons.account_circle,
          label: appLocalizations
              .tr('irc.connection.preferences.user.field.real_name.label'),
          hint: appLocalizations
              .tr('irc.connection.preferences.user.field.real_name.hint'),
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.userNameFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.userNameFieldBloc,
          controller: _userNameController,
          icon: Icons.account_circle,
          label: appLocalizations
              .tr('irc.connection.preferences.user.field.user_name.label'),
          hint: appLocalizations
              .tr('irc.connection.preferences.user.field.user_name.hint'),
          textInputAction: TextInputAction.done,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.commandsFieldBloc,
          controller: _commandsController,
          icon: Icons.settings,
          label: appLocalizations
              .tr('irc.connection.preferences.user.field.commands.label'),
          hint: appLocalizations
              .tr('irc.connection.preferences.user.field.commands.hint'),
          textInputAction: TextInputAction.newline,
          minLines: 1,
          maxLines: 4,
        ),
      ],
    );
  }
}
