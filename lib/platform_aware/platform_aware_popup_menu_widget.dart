import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';

var _logger = Logger("platform_aware_popup_menu_widget.dart");

class PlatformAwarePopupMenuAction {
  final IconData iconData;
  final String text;
  final Function(PlatformAwarePopupMenuAction action) actionCallback;

  PlatformAwarePopupMenuAction({
    @required this.iconData,
    @required this.text,
    @required this.actionCallback,
  });
}

Widget createPlatformPopupMenuButton(
  BuildContext context, {
  @required Widget child,
  @required List<PlatformAwarePopupMenuAction> actions,
  bool enabled = true,
  bool isNeedPadding = true,
}) {
  var platformProviderState = PlatformProvider.of(context);

  switch (platformProviderState.platform) {
    case TargetPlatform.android:
      return _buildMaterialPopupButton(
        child,
        actions,
        enabled,
        isNeedPadding,
      );
      break;
    case TargetPlatform.iOS:
      return _buildCupertinoPopupButton(
        context,
        child,
        actions,
        enabled,
        isNeedPadding,
      );
      break;
    default:
      throw Exception("invalid platform");
  }
}

Widget _buildCupertinoPopupButton(
  BuildContext context,
  Widget child,
  List<PlatformAwarePopupMenuAction> actions,
  bool enabled,
  bool isNeedPadding,
) {
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
      padding:
          isNeedPadding ? const EdgeInsets.all(4.0) : const EdgeInsets.all(0.0),
      child: child,
    );

    return GestureDetector(
      onTap: onPressed,
      child: childWithPadding,
    );
  }
}

Future showPlatformAwarePopup(
  BuildContext context,
  RelativeRect position,
  List<PlatformAwarePopupMenuAction> actions,
) {
  var platformProviderState = PlatformProvider.of(context);

  switch (platformProviderState.platform) {
    case TargetPlatform.android:
      return showMaterialPopup(context, position, actions);
      break;
    case TargetPlatform.iOS:
      return showCupertinoPopup(context, actions);
      break;
    default:
      throw Exception("invalid platform");
  }
}

Future showMaterialPopup<T>(BuildContext context, RelativeRect position,
    List<PlatformAwarePopupMenuAction> actions) {
  return showMenu(
    context: context,
    position: position,
    items: _convertToMaterialActions(
      actions,
    ),
  ).then(
    (selectedAction) {
      selectedAction?.actionCallback(selectedAction);
    },
  );
}

Future showCupertinoPopup<T>(
  BuildContext context,
  List<PlatformAwarePopupMenuAction> actions,
) {
  return showCupertinoModalPopup(
    context: context,
    builder: (_) {
      return CupertinoActionSheet(
        actions: actions
            .map(
              (action) => CupertinoActionSheetAction(
                child: _buildRow(action.iconData, action.text),
                onPressed: () {
                  Navigator.pop(context);
                  action.actionCallback(action);
                },
              ),
            )
            .toList(),
      );
    },
  );
}

Widget _buildMaterialPopupButton(
  Widget child,
  List<PlatformAwarePopupMenuAction> actions,
  bool enabled,
  bool isNeedPadding,
) {
  _logger.fine(() => "_buildMaterialPopupButton $enabled");

  if (child is Icon && !enabled) {
    // hack because enabled don't change icon color to disabled color
    // when enabled == false
    // TODO: fix when bug will be fixed
    return PlatformIconButton(icon: child);
  } else {
    return PopupMenuButton(
      enabled: enabled,
      child: Padding(
        padding: isNeedPadding
            ? const EdgeInsets.symmetric(horizontal: 8.0)
            : const EdgeInsets.all(0),
        child: child,
      ),
      itemBuilder: (_) => _convertToMaterialActions(actions),
      onSelected: enabled
          ? (PlatformAwarePopupMenuAction selectedItem) {
              selectedItem.actionCallback(selectedItem);
            }
          : null,
    );
  }
}

List<PopupMenuItem<PlatformAwarePopupMenuAction>> _convertToMaterialActions(
  List<PlatformAwarePopupMenuAction> actions,
) =>
    actions
        .map(
          (action) => _buildDropdownMenuItemRow(
            text: action.text,
            iconData: action.iconData,
            value: action,
          ),
        )
        .toList();

PopupMenuItem<T> _buildDropdownMenuItemRow<T>({
  @required String text,
  @required IconData iconData,
  @required T value,
}) =>
    PopupMenuItem<T>(
      value: value,
      child: _buildRow(iconData, text),
    );

Row _buildRow(
  IconData iconData,
  String text,
) {
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
