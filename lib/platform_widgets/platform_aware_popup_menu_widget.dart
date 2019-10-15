import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware.dart';

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
    @required List<PlatformAwarePopupMenuAction> actions}) {
  switch (detectCurrentUIPlatform()) {
    case UIPlatform.MATERIAL:
      return _buildMaterialPopupButton(child, actions);
      break;
    case UIPlatform.CUPERTINO:
      return _buildCupertinoPopupButton(context, child, actions);
      break;
  }
  throw Exception("invalid platform");
}

Widget _buildCupertinoPopupButton(BuildContext context, Widget child,
    List<PlatformAwarePopupMenuAction> actions) {
  return GestureDetector(
      onTap: () {
        showCupertinoPopup(context, actions);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: child,
      ));
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

PopupMenuButton<PlatformAwarePopupMenuAction> _buildMaterialPopupButton(
    Widget child, List<PlatformAwarePopupMenuAction> actions) {
  return PopupMenuButton(
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: child,
    ),
    itemBuilder: (_) => convertToMaterialActions(actions),
    onSelected: (PlatformAwarePopupMenuAction selectedItem) {
      selectedItem.actionCallback(selectedItem);
    },
  );
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
