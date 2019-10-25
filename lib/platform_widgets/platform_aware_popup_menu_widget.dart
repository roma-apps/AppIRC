import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

MyLogger _logger =
    MyLogger(logTag: "platform_aware_popup_menu_widget.dart", enabled: true);

class PlatformAwarePopupMenuAction {
  final IconData iconData;
  final String text;
  final Function(PlatformAwarePopupMenuAction action) actionCallback;

  PlatformAwarePopupMenuAction(
      {@required this.iconData,
      @required this.text,
      @required this.actionCallback});
}

Widget createPlatformPopupMenuButton(BuildContext context,
    {@required Widget child,
    @required List<PlatformAwarePopupMenuAction> actions,
    bool enabled = true}) {
  switch (detectCurrentUIPlatform()) {
    case UIPlatform.MATERIAL:
      return _buildMaterialPopupButton(child, actions, enabled);
      break;
    case UIPlatform.CUPERTINO:
      return _buildCupertinoPopupButton(context, child, actions, enabled);
      break;
  }
  throw Exception("invalid platform");
}

Widget _buildCupertinoPopupButton(BuildContext context, Widget child,
    List<PlatformAwarePopupMenuAction> actions, bool enabled) {
  var onPressed;

  if (enabled) {
    onPressed = () {
      showCupertinoPopup(context, actions);
    };
  }

  if (child is Icon) {
    return PlatformIconButton(icon: child, onPressed: onPressed);
  } else {
    var childWithPadding = Padding(
      padding: const EdgeInsets.all(4.0),
      child: child,
    );
    return PlatformButton(onPressed: onPressed, child: childWithPadding);
  }
}

showPlatformAwarePopup(BuildContext context, RelativeRect position,
    List<PlatformAwarePopupMenuAction> actions) {
  switch (detectCurrentUIPlatform()) {
    case UIPlatform.MATERIAL:
      return showMaterialPopup(context, position, actions);
      break;
    case UIPlatform.CUPERTINO:
      return showCupertinoPopup(context, actions);
      break;
  }
  throw Exception("invalid platform");
}

showMaterialPopup(BuildContext context, RelativeRect position,
    List<PlatformAwarePopupMenuAction> actions) async {
  showMenu(
          context: context,
          position: position,
          items: convertToMaterialActions(actions))
      .then((selected) {
    selected?.actionCallback(selected);
  });
}

showCupertinoPopup(
    BuildContext context, List<PlatformAwarePopupMenuAction> actions) {
  return showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          actions: actions
              .map((action) => CupertinoActionSheetAction(
                    child: _buildRow(action.iconData, action.text),
                    onPressed: () {
                      Navigator.pop(context);
                      action.actionCallback(action);
                    },
                  ))
              .toList(),
        );
      });
}

Widget _buildMaterialPopupButton(
    Widget child, List<PlatformAwarePopupMenuAction> actions, bool enabled) {
  _logger.d(() => "_buildMaterialPopupButton $enabled");

  if (child is Icon && !enabled) {
    // hack because enabled don't change icon color to disabled color
    // when enabled == false
    // TODO: fix when bug will be fixed
    return PlatformIconButton(icon: child);
  } else {
    return PopupMenuButton(
      enabled: enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: child,
      ),
      itemBuilder: (_) => convertToMaterialActions(actions),
      onSelected: enabled
          ? (PlatformAwarePopupMenuAction selectedItem) {
              selectedItem.actionCallback(selectedItem);
            }
          : null,
    );
  }
}

List<PopupMenuItem<PlatformAwarePopupMenuAction>> convertToMaterialActions(
    List<PlatformAwarePopupMenuAction> actions) {
  return actions
      .map((action) => buildDropdownMenuItemRow(
          text: action.text, iconData: action.iconData, value: action))
      .toList();
}

PopupMenuItem<T> buildDropdownMenuItemRow<T>(
        {@required String text,
        @required IconData iconData,
        @required T value}) =>
    PopupMenuItem<T>(
      value: value,
      child: _buildRow(iconData, text),
    );

Row _buildRow(IconData iconData, String text) {
  return Row(
    children: <Widget>[
      Icon(iconData),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
    ],
  );
}
