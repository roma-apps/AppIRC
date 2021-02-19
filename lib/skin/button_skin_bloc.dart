
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

abstract class ButtonSkinBloc extends SkinBloc {
  Color get enabledColor;

  Color get disabledColor;

  Color get textColor;
}

Widget createSkinnedPlatformButton(BuildContext context,
    {Key widgetKey,
    @required VoidCallback onPressed,
    @required Widget child,
    EdgeInsetsGeometry padding}) {
  var buttonSkinBloc = Provider.of<ButtonSkinBloc>(context);
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: PlatformButton(
      child: child,
      onPressed: onPressed,
      materialFlat: (context, platform) => MaterialFlatButtonData(
        color: buttonSkinBloc.enabledColor,
        disabledColor: buttonSkinBloc.disabledColor,

      ),
      cupertino: (context, platform) => CupertinoButtonData(
        color: buttonSkinBloc.enabledColor,
        disabledColor: buttonSkinBloc.disabledColor
      ),
    ),
  );
}
