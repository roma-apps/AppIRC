import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_alert_dialog.dart';

Future showLoungeTimeoutAlertDialog(BuildContext context) async {
  var appLocalizations = AppLocalizations.of(context);

  String title =
  appLocalizations.tr('lounge.dialog.timeout.title');

  String content = appLocalizations
      .tr('lounge.dialog.timeout.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}


Future showLoungeConnectionErrorAlertDialog(
    BuildContext context, dynamic error) async {
  var appLocalizations = AppLocalizations.of(context);

  String title = appLocalizations
      .tr('lounge.dialog.connection_error.title');

  String content;
  if (error != null) {
    content = appLocalizations.tr(
        'lounge.dialog.connection_error'
            '.content.with_exception',
        args: [error]);
  } else {
    content = appLocalizations
        .tr('lounge.dialog.connection_error.content'
        '.no_exception');
  }

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}



Future showLoungeInvalidResponseDialog(BuildContext context,
    InvalidResponseException exception) async {
  var appLocalizations = AppLocalizations.of(context);

  String title = appLocalizations.tr(
      'lounge.dialog.invalid_response_error.title');

  String content = appLocalizations.tr(
      'lounge.dialog.invalid_response_error.content');

  return showPlatformAlertDialog(
      context: context, title: Text(title), content: Text(content));
}
