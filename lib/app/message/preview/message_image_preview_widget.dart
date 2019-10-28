import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';

Widget buildMessageImagePreview(
    {@required BuildContext context, @required MessagePreview preview}) {
  return buildPreviewImageThumb(context, preview.thumb);
}

Widget buildPreviewImageThumb(BuildContext context, String thumb) {
  return Image.network(thumb);
}
