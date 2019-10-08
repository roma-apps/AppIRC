import 'package:flutter/material.dart';
import 'package:flutter_appirc/async/async_dialog_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';

abstract class ProgressDialogSkinBloc extends SkinBloc {
  Color get backgroundColor;

  TextStyle get messageTextStyle;
}

ProgressDialog createSkinnedProgressDialog(BuildContext context,
    {ProgressDialogType type, bool isDismissible, bool showLogs}) {
  var progressDialog = ProgressDialog(context,
      type: type, isDismissible: isDismissible, showLogs: showLogs);

  ProgressDialogSkinBloc skinBloc = Provider.of(context);

  progressDialog.style(
      backgroundColor: skinBloc.backgroundColor,
      messageTextStyle: skinBloc.messageTextStyle);

  return progressDialog;
}
