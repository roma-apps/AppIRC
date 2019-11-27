import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';

import 'message_image_preview_widget.dart';

Widget buildMessageLinkPreview(
    {@required BuildContext context, @required MessagePreview preview}) {
  TextSkinBloc textSkinBloc = Provider.of(context);
  var rows = <Widget>[
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:8.0),
      child: Text(preview.head, style: textSkinBloc.defaultTextStyle.copyWith
        (fontWeight: FontWeight.bold)),
    ),
    Padding(
      padding: const EdgeInsets.symmetric(vertical:8.0),
      child: Text(preview.body, style: textSkinBloc.defaultTextStyle),
    ),
  ];

  if (preview.thumb != null) {
    rows.add(buildPreviewImageThumb(context, preview.thumb));
  }
  return Column(children: rows);
}
