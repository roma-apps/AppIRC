import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/async_dialog_skin_bloc.dart';
import 'package:flutter_appirc/async/async_dialog_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';


var _logger = MyLogger(logTag: "doAsyncOperationWithDialog", enabled: true);

Future<T> doAsyncOperationWithDialog<T>(BuildContext context,
    Future<T> asyncCode()) async {
//For normal dialog
  var pr = createSkinnedProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

  pr.show();
  var result;
  try {
    result = await asyncCode();
  } finally {
    // bug in progress library. Sometimes dialog not dismissed without additional wait
    await Future.delayed(Duration(milliseconds: 100));
    var hide = await pr.hide();
    _logger.d(() => "progress dialog hide = $hide");



  }

  return result;
}


