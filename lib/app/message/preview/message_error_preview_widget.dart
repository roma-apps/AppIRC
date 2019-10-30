import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/message/preview/message_preview_model.dart';

Widget buildMessageErrorPreview(
    {@required BuildContext context, @required MessagePreview preview}) {
  return Text(AppLocalizations.of(context).tr("chat.message.preview.error"
      ".server"));
}
