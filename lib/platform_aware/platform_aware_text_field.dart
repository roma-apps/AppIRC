import 'package:flutter/cupertino.dart' show OverlayVisibilityMode;
import 'package:flutter/material.dart' show InputDecoration;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

PlatformTextField buildPlatformTextField({
  @required BuildContext context,
  @required TextEditingController controller,
  @required String label,
  @required String hint,
  @required TextStyle labelStyle,
  @required TextStyle hintStyle,
  @required TextStyle editStyle,
  TextStyle disabledLabelStyle,
  TextStyle disabledHintStyle,
  TextStyle disabledEditStyle,
  bool enabled = true,
  Function(String newValue) onChanged,
  FocusNode focusNode,
  TextInputType keyboardType,
  List<TextInputFormatter> formatters,
  int maxLength,
  int minLines,
  int maxLines,
  bool obscureText = false,
  bool autoCorrect = false,
  TextAlign textAlign: TextAlign.start,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
  TextInputAction textInputAction = TextInputAction.next,
  bool expands = false,
  VoidCallback onEditingComplete,
  ValueChanged<String> onSubmitted,
}) {
  var androidBuilder;
  var iosBuilder;

  assert(enabled != null);

  TextStyle _editStyle = enabled ? editStyle : disabledEditStyle;
  TextStyle _hintStyle = enabled ? hintStyle : disabledHintStyle;
  TextStyle _labelStyle = enabled ? labelStyle : disabledLabelStyle;

  androidBuilder = (_) {
    return MaterialTextFieldData(
        enabled: enabled,
        enableInteractiveSelection: true,
        style: _editStyle,
        decoration: InputDecoration(
            enabled: enabled,
            labelText: label,
            hintText: hint,
            labelStyle: _labelStyle,
            hintStyle: _hintStyle));
  };

  iosBuilder = (_) => CupertinoTextFieldData(
      enabled: enabled,
      placeholder: hint,
      padding: EdgeInsets.all(8),
      style: _editStyle,
      prefixMode: OverlayVisibilityMode.notEditing,
      prefix: label != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                style: _labelStyle,
              ),
            )
          : null,
      placeholderStyle: _hintStyle);

  var platformTextField = PlatformTextField(
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters: formatters,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      autocorrect: autoCorrect,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      expands: expands,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      android: androidBuilder,
      ios: iosBuilder,
      controller: controller,
      onChanged: onChanged);
  return platformTextField;
}
