import 'package:async/async.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/async/async_dialog_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "doAsyncOperationWithDialog", enabled: true);

Future<AsyncDialogResult<T>> doAsyncOperationWithDialog<T>(
  BuildContext context, {
  @required Future<T> asyncCode(),
  @required T cancellationValue,
  @required bool isDismissible,
  Widget title,
  Widget content,
  Widget cancelAction,
}) async {
  T result;
  var cancelableOperation = CancelableOperation.fromFuture(asyncCode());
  var progressDialog = AsyncProgressDialog(
      cancelableOperation: cancelableOperation,
      title: title,
      content: content,
      cancelAction: cancelAction);
  progressDialog.show(context);
  try {
    result = await cancelableOperation.valueOrCancellation(cancellationValue);
  } finally {
    var hide = progressDialog.hide(context);
    _logger.d(() => "progress dialog hide = $hide");
  }

  var dialogResult = AsyncDialogResult(result, cancelableOperation.isCanceled);
  _logger.d(() => "progress dialogResult = $dialogResult");
  return dialogResult;
}

class AsyncProgressDialog {
  bool _isShowing = false;
  final CancelableOperation cancelableOperation;

  bool get isShowing => _isShowing;

//  BuildContext _dismissingContext;

  final Widget title;
  final Widget content;
  final Widget cancelAction;

  AsyncProgressDialog(
      {this.cancelableOperation, this.title, this.content, this.cancelAction});

  bool hide(BuildContext context) {
    bool result;
    if (_isShowing) {
      try {
        _isShowing = false;
//        Navigator.of(_dismissingContext).pop(true);
        Navigator.of(context).pop();
        result = true;
      } catch (_) {
        result = false;
      }
    } else {
      result = false;
    }
//    _dismissingContext = null;
    return result;
  }

  void show(BuildContext context) {
    if (!_isShowing) {
      _isShowing = true;

      showPlatformDialog(
        context: context,
        androidBarrierDismissible: false,
        builder: (BuildContext context) {
//          _dismissingContext = context;

          List<Widget> actions = [];
          if (cancelableOperation != null) {
            actions.add(PlatformDialogAction(
                child: cancelAction ??
                    Text(AppLocalizations.of(context).tr("dialog.async"
                        ".action.cancel")),
                onPressed: () {
                  cancelableOperation.cancel();
                  hide(context);
                }));
          }

          return PlatformAlertDialog(
            title: title ??
                Text(AppLocalizations.of(context).tr("dialog.async.title")),
            content: content ??
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[PlatformCircularProgressIndicator()]),
            actions: actions,
          );
        },
      );
    }
  }
}
