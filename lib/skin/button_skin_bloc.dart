import 'package:flutter/material.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

abstract class ButtonSkinBloc extends SkinBloc {
  Color get enabledColor;

  Color get disabledColor;
}

PlatformButton createSkinnedPlatformButton(BuildContext context,
    {Key widgetKey,
    @required VoidCallback onPressed,
    @required Widget child,
    EdgeInsetsGeometry padding}) {
//  var buttonSkinBloc = Provider.of<ButtonSkinBloc>(context);
  return PlatformButton(
      child: child,
      onPressed: onPressed);
}
