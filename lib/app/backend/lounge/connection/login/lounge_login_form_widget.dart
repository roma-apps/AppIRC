import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/login/lounge_login_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';

class LoungeLoginFormWidget extends StatelessWidget {
  final LoungeLoginFormBloc loginFormBloc;

  LoungeLoginFormWidget(this.loginFormBloc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Provider<LoungeAuthPreferencesFormBloc>(
          providable: loginFormBloc,
          child: LoungeAuthPreferencesFormWidget(
              AppLocalizations.of(context).tr('lounge.preferences.login.title'),
              loginFormBloc),
        )
      ],
    );
  }
}

Future showLoungeLoginFailAlertDialog(BuildContext context) async {
  var appLocalizations = AppLocalizations.of(context);

  String title =
      appLocalizations.tr('lounge.preferences.login.dialog.login_fail.title');

  String content =
      appLocalizations.tr('lounge.preferences.login.dialog.login_fail.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}
