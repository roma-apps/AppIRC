import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';

Future showLoungeTimeoutAlertDialog(BuildContext context) async {

  String title = tr('lounge.dialog.timeout.title');

  String content = tr('lounge.dialog.timeout.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}


Future showLoungeConnectionErrorAlertDialog(
    BuildContext context, dynamic error) async {

  String title = tr('lounge.dialog.connection_error.title');

  String content;
  if (error != null) {
    content = tr(
        'lounge.dialog.connection_error'
            '.content.with_exception',
        args: [error]);
  } else {
    content = tr('lounge.dialog.connection_error.content'
        '.no_exception');
  }

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}



Future showLoungeInvalidResponseDialog(BuildContext context,
    InvalidResponseException exception) async {


  String title = tr(
      'lounge.dialog.invalid_response_error.title');

  String content = tr(
      'lounge.dialog.invalid_response_error.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}
