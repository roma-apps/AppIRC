import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/registration/lounge_registration_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';

class LoungeRegistrationFormWidget extends StatelessWidget {
  final LoungeRegistrationFormBloc registrationFormBloc;

  LoungeRegistrationFormWidget(this.registrationFormBloc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        LoungeAuthPreferencesFormWidget(
            tr('lounge.preferences.registration'
                '.title'),
            registrationFormBloc),
      ],
    );
  }
}

Future showLoungeRegistrationInvalidAlertDialog(BuildContext context) async {

  String title = tr('lounge.preferences.registration.dialog.error_invalid.title');

  String content = tr('lounge.preferences.registration.dialog.error_invalid.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}

Future showLoungeRegistrationUnknownAlertDialog(BuildContext context) async {

  String title = tr('lounge.preferences.registration.dialog.error_unknown.title');

  String content = tr('lounge.preferences.registration.dialog.error_unknown.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}

Future showLoungeRegistrationAlreadyExistAlertDialog(
    BuildContext context) async {

  String title = tr('lounge.preferences.registration.dialog.error_already_exist.title');

  String content = tr('lounge.preferences.registration.dialog.error_already_exist.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}

Future showLoungeRegistrationSuccessAlertDialog(BuildContext context) async {

  String title = tr('lounge.preferences.registration.dialog.success.title');

  String content = tr('lounge.preferences.registration.dialog.success.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}
