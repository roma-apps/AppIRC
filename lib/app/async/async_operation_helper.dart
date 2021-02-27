import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/dialog/async/async_dialog_model.dart';

class AsyncOperationHelper {
  static const List<ErrorDataBuilder> defaultErrorDataBuilders = [];

  static Future<AsyncDialogResult<T>> performAsyncOperation<T>({
    @required BuildContext context,
    @required Future<T> asyncCode(),
    String contentMessage,
    List<ErrorDataBuilder> errorDataBuilders = defaultErrorDataBuilders,
    bool createDefaultErrorDataUnhandledError = true,
    bool showProgressDialog = true,
    ErrorCallback errorCallback,
    bool cancelable = false,
  }) =>
      doAsyncOperationWithDialog(
        context: context,
        asyncCode: asyncCode,
        errorCallback: (context, errorData) {
          if (errorCallback != null) {
            errorCallback(context, errorData);
          }
        },
        contentMessage: contentMessage,
        errorDataBuilders: errorDataBuilders,
        showDefaultErrorAlertDialogOnUnhandledError:
            createDefaultErrorDataUnhandledError,
        showProgressDialog: showProgressDialog,
        cancelable: cancelable,
      );
}
