//import 'package:flutter/material.dart';
//import 'package:flutter_appirc/async/async_dialog.dart';
//import 'package:flutter_appirc/async/async_dialog_widget.dart';
//import 'package:flutter_appirc/provider/provider.dart';
//import 'package:flutter_appirc/skin/skin_bloc.dart';
//
//abstract class ProgressDialogSkinBloc extends SkinBloc {
//  Color get backgroundColor;
//
//  TextStyle get messageTextStyle;
//}
//
////AsyncProgressDialog createSkinnedProgressDialog(BuildContext context,
////    {@required bool isCancelable}) {
////  var progressDialog = AsyncProgressDialog(context, isCancelable: isCancelable);
////
////  ProgressDialogSkinBloc skinBloc = Provider.of(context);
////
////  TextStyle _progressTextStyle = TextStyle(
////      color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
////      _messageStyle = TextStyle(
////          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600);
////
////  double _dialogElevation = 8.0, _borderRadius = 8.0;
////  Color _backgroundColor = Colors.white;
////  Curve _insetAnimCurve = Curves.easeInOut;
////
////  progressDialog.style(
////      backgroundColor: skinBloc.backgroundColor,
////      messageTextStyle: skinBloc.messageTextStyle);
////
////  return progressDialog;
////}
