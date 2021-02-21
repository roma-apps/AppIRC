import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';

Widget buildMessageLoadingPreview({
  @required BuildContext context,
  @required MessagePreview preview,
}) =>
    Text(
      S.of(context).chat_message_preview_loading
    );
