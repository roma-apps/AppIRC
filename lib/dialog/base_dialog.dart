import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/dialog/dialog_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/generated/l10n.dart';

abstract class IDialog {
  bool get isShowing;

  bool get cancelable;

  Future<T> show<T>(BuildContext context);

  Future hide(BuildContext context);
}

abstract class BaseDialog extends DisposableOwner implements IDialog {
  @override
  final bool cancelable;

  BaseDialog({this.cancelable = true});

  bool _isShowing = false;

  @override
  bool get isShowing => _isShowing;

  @override
  Future<T> show<T>(BuildContext context) async {
    assert(!isShowing);
    _isShowing = true;
    var result = await showDialog<T>(
      barrierDismissible: cancelable,
      context: context,
      builder: (BuildContext context) => buildDialogBody(context),
    );
    await dispose();
    return result;
  }

  @override
  Future hide(BuildContext context) async {
    assert(isShowing);
    _isShowing = false;
    await dispose();
    Navigator.of(context).pop();
  }

  Widget buildDialogBody(BuildContext context);

  static DialogAction createDefaultCancelAction({
    @required BuildContext context,
  }) =>
      DialogAction(
        onAction: (context) {
          Navigator.of(context).pop();
        },
        label: S.of(context).dialog_action_cancel,
      );

  static DialogAction createDefaultOkAction({
    @required BuildContext context,
    @required DialogActionCallback action,
    DialogActionEnabledFetcher isActionEnabledFetcher,
    DialogActionEnabledStreamFetcher isActionEnabledStreamFetcher,
  }) =>
      DialogAction(
        onAction: (context) {
          if (action != null) {
            action(context);
          }
          Navigator.of(context).pop();
        },
        label: S.of(context).dialog_action_ok,
        isActionEnabledFetcher: isActionEnabledFetcher,
        isActionEnabledStreamFetcher: isActionEnabledStreamFetcher,
      );
}
