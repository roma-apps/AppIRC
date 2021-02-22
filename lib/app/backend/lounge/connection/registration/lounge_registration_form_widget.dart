import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';

class LoungeRegistrationFormWidget extends StatelessWidget {
  LoungeRegistrationFormWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        LoungeAuthPreferencesFormWidget(
          titleText:S.of(context).lounge_preferences_registration_title,
        ),
      ],
    );
  }
}

Future showLoungeRegistrationInvalidAlertDialog(BuildContext context) async {
  String title =
      S.of(context).lounge_preferences_registration_dialog_error_invalid_title;
  String content = S
      .of(context)
      .lounge_preferences_registration_dialog_error_invalid_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}

Future showLoungeRegistrationUnknownAlertDialog(BuildContext context) async {
  String title =
      S.of(context).lounge_preferences_registration_dialog_error_unknown_title;
  String content = S
      .of(context)
      .lounge_preferences_registration_dialog_error_unknown_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}

Future showLoungeRegistrationAlreadyExistAlertDialog(
    BuildContext context) async {
  String title = S
      .of(context)
      .lounge_preferences_registration_dialog_error_already_exist_title;
  String content = S
      .of(context)
      .lounge_preferences_registration_dialog_error_already_exist_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}

Future showLoungeRegistrationSuccessAlertDialog(BuildContext context) async {
  String title =
      S.of(context).lounge_preferences_registration_dialog_success_title;
  String content =
      S.of(context).lounge_preferences_registration_dialog_success_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}
