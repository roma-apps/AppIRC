import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/login/lounge_login_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';
import 'package:provider/provider.dart';

class LoungeLoginFormWidget extends StatelessWidget {
  final LoungeLoginFormBloc loginFormBloc;

  LoungeLoginFormWidget(this.loginFormBloc);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Provider<LoungeAuthPreferencesFormBloc>.value(
          value: loginFormBloc,
          child: LoungeAuthPreferencesFormWidget(
            S.of(context).lounge_preferences_login_title,
            loginFormBloc,
          ),
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
