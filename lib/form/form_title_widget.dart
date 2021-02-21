import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';

Widget buildFormTitle({
  @required BuildContext context,
  @required String title,
}) {
  var appIrcUiTextTheme = IAppIrcUiTextTheme.of(context);

  return Padding(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: appIrcUiTextTheme.bigTallMediumGrey,
        ),
        const Divider(),
      ],
    ),
    padding: const EdgeInsets.all(4.0),
  );
}
