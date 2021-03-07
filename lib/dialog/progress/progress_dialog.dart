import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/dialog/base_dialog.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:rxdart/rxdart.dart';

abstract class ProgressDialog extends BaseDialog {
  final String titleMessage;
  final String contentMessage;

  CancelableOperation cancelableOperation;

  // ignore: close_sinks
  final BehaviorSubject<bool> _isCanceledSubject =
      BehaviorSubject.seeded(false);

  bool get isCanceled => _isCanceledSubject.value;

  Stream<bool> get isCanceledStream => _isCanceledSubject.stream;

  ProgressDialog({
    this.titleMessage,
    this.contentMessage,
    @required this.cancelableOperation,
    @required bool cancelable,
  }) : super(cancelable: cancelable) {
    addDisposable(subject: _isCanceledSubject);
  }

  Widget buildDialogTitle(BuildContext context);

  Widget buildDialogTitleMessage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        titleMessage ?? S.of(context).dialog_progress_content,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildDialogContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Text(
        contentMessage,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget buildDialogBody(BuildContext context) => Dialog(
      insetAnimationCurve: Curves.easeInOut,
      insetAnimationDuration: Duration(milliseconds: 100),
      elevation: 10.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: buildDialogContainer(context));

  Widget buildDialogContainer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircularProgressIndicator(),
          ),
          buildDialogTitle(context),
          if (contentMessage != null) buildDialogContent(context),
          if (cancelable)
            StreamBuilder<bool>(
              stream: isCanceledStream,
              initialData: isCanceled,
              builder: (context, snapshot) {
                var canceled = snapshot.data;
                Future<Null> Function() onPressed;

                if (!canceled) {
                  onPressed = () async {
                    _isCanceledSubject.add(true);
                    await cancelableOperation.cancel();
                    if (isShowing) {
                      await hide(context);
                    }
                  };
                }
                return GestureDetector(
                  child: Text(
                    S.of(context).dialog_progress_action_cancel,
                  ),
                  onTap: onPressed,
                );
              },
            )
        ],
      ),
    );
  }
}
