import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void showPlatformAlertDialog({
  @required BuildContext context,
  Widget title,
  Widget content,
}) async =>
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: title,
        content: content,
        actions: <Widget>[
          PlatformDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).dialog_alert_action_ok,
            ),
          )
        ],
      ),
      androidBarrierDismissible: true,
    );
