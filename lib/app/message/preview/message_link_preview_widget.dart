import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';

import 'message_image_preview_widget.dart';

Widget buildMessageLinkPreview({
  @required BuildContext context,
  @required MessagePreview preview,
}) {
  var rows = <Widget>[
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        preview.head,
        style: IAppIrcUiTextTheme.of(context).mediumBoldDarkGrey,
      ),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        preview.body,
        style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
      ),
    ),
  ];

  if (preview.thumb != null) {
    rows.add(
      buildPreviewImageThumb(
        context,
        preview.thumb,
      ),
    );
  }
  return Column(children: rows);
}
