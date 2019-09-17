import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:progress_dialog/progress_dialog.dart';

var _logger = MyLogger(logTag: "doAsyncOperationWithDialog", enabled: true);

Future<T> doAsyncOperationWithDialog<T>(BuildContext context,
    Future<T> asyncCode()) async {
//For normal dialog
  var pr = new ProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);

  pr.show();
  var result;
  try {
    result = await asyncCode();
  } on Exception catch (e) {
    _logger.e(() => "error $e");
    pr.hide();
  } finally {
    pr.hide();
  }

  pr.hide();

  return result;
}
