import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void showPlatformAlertDialog(
        {@required BuildContext context,
        Widget title,
        Widget content}) async =>
    showPlatformDialog(
        context: context,
        builder: (context) => PlatformAlertDialog(
              title: title,
              content: content,
              actions: <Widget>[
                PlatformDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr("dialog.alert.action.ok")),
                )
              ],
            ),
        androidBarrierDismissible: true);
