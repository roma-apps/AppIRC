import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/dialog/progress/progress_dialog.dart';

class IndeterminateProgressDialog extends ProgressDialog {
  IndeterminateProgressDialog({
    String titleMessage,
    String contentMessage,
    bool cancelable = false,
    @required CancelableOperation cancelableOperation,
  }) : super(
            titleMessage: titleMessage,
            contentMessage: contentMessage,
            cancelable: cancelable,
            cancelableOperation: cancelableOperation);

  @override
  Widget buildDialogTitle(BuildContext context) =>
      buildDialogTitleMessage(context);
}
