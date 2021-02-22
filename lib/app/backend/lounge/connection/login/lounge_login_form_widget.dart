import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';

class LoungeLoginFormWidget extends StatelessWidget {
  LoungeLoginFormWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        LoungeAuthPreferencesFormWidget(
          titleText: S.of(context).lounge_preferences_login_title,
        )
      ],
    );
  }
}

Future showLoungeLoginFailAlertDialog(BuildContext context) async {
  String title = S.of(context).lounge_preferences_login_dialog_login_fail_title;
  String content =
      S.of(context).lounge_preferences_login_dialog_login_fail_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}
