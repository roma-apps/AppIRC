import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

PlatformDialogAction createOkPlatformDialogAction(BuildContext context) {
  return PlatformDialogAction(
    child: Text(AppLocalizations.of(context).tr("button.ok")),
    onPressed: () => Navigator.pop(context),
  );
}
