import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/dialog/async/async_dialog_model.dart';
import 'package:flutter_appirc/dialog/progress/indeterminate_progress_dialog.dart';
import 'package:flutter_appirc/error/error_data_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:logging/logging.dart';

var _logger = Logger("async_dialog.dart");

typedef ErrorData ErrorDataBuilder(
  BuildContext context,
  dynamic error,
  StackTrace stackTrace,
);

typedef void ErrorCallback(BuildContext context, ErrorData errorData);

Future<AsyncDialogResult<T>> doAsyncOperationWithDialog<T>({
  @required BuildContext context,
  @required Future<T> asyncCode(),
  ErrorCallback errorCallback,
  String contentMessage,
  List<ErrorDataBuilder> errorDataBuilders = const [],
  bool showDefaultErrorAlertDialogOnUnhandledError = true,
  bool showProgressDialog = true,
  bool cancelable = false,
}) async {
  T result;
  CancelableOperation<T> cancelableOperation =
      CancelableOperation.fromFuture(asyncCode());

  var progressDialog;
  if (showProgressDialog) {
    progressDialog = IndeterminateProgressDialog(
        cancelable: cancelable,
        contentMessage: contentMessage,
        cancelableOperation: cancelableOperation);
    progressDialog.show(context);
  }

  var error;
  ErrorData errorData;

  var needRethrow = true;

  try {
    result = await cancelableOperation.valueOrCancellation(null);
  } catch (e, stackTrace) {
    error = e;
    for (ErrorDataBuilder builder in errorDataBuilders ?? []) {
      errorData = builder(context, e, stackTrace);
      if (errorData != null) {
        needRethrow = false;
        break;
      }
    }

    if (errorData == null && showDefaultErrorAlertDialogOnUnhandledError) {
      errorData = ErrorData(
        titleCreator: (context) => S.of(context).dialog_error_title,
        contentCreator: (context) => S.of(context).dialog_error_content(
              error.toString(),
            ),
        stackTrace: null,
        error: null,
      );
    }

    if (needRethrow) {
      _logger.severe(
          () => "rethrow error during "
              "doAsyncOperationWithAppIrcDialog",
          error,
          stackTrace);
    } else {
      _logger.warning(
          () => "handled error during "
              "doAsyncOperationWithAppIrcDialog",
          error,
          stackTrace);
    }
  } finally {
    progressDialog?.hide(context);
  }

  // wait until progress dialog actually hides
  await Future.delayed(Duration(milliseconds: 100), () {

  });

  AsyncDialogResult dialogResult;
  if (progressDialog?.isCanceled == true) {
    dialogResult = AsyncDialogResult<T>.canceled();
    _logger.fine(() => "canceled doAsyncOperationWithAppIrcDialog");
  } else if (error != null) {
    if (errorData != null) {
      if (errorCallback != null) {
        errorCallback(context, errorData);
      }
    }

    if (needRethrow) {
      throw error;
    }
    dialogResult = AsyncDialogResult<T>.withError(error);
  } else {
    _logger.finest(() => "success doAsyncOperationWithAppIrcDialog =$result}");
    dialogResult = AsyncDialogResult<T>.success(result);
  }

  return dialogResult;
}
