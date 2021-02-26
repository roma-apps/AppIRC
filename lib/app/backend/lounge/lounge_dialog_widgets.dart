import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';

Future showLoungeTimeoutAlertDialog(BuildContext context) async {
  String title = S.of(context).lounge_dialog_timeout_title;
  String content = S.of(context).lounge_dialog_timeout_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(
      content,
    ),
  );
}

Future showLoungeConnectionErrorAlertDialog(
    BuildContext context, dynamic error) async {
  String title = S.of(context).lounge_dialog_connection_error_title;

  String content;
  if (error != null) {
    content = S
        .of(context)
        .lounge_dialog_connection_error_content_with_exception(error);
  } else {
    content = S.of(context).lounge_dialog_connection_error_content_no_exception;
  }

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}

Future showLoungeInvalidResponseDialog(
    BuildContext context) async {
  String title = S.of(context).lounge_dialog_invalid_response_error_title;
  String content = S.of(context).lounge_dialog_invalid_response_error_content;

  return showPlatformAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}
