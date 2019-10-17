
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/form/form_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

PlatformTextField buildPlatformTextField(
    BuildContext context,
    FormValueFieldBloc<String> bloc,
    TextEditingController controller,
    String labelText,
    String hint, {
      TextInputType keyboardType,
      List<TextInputFormatter> formatters,
      int maxLength,
      int minLines,
      int maxLines,
      bool obscureText = false,
      bool autocorrect = false,
      TextAlign textAlign: TextAlign.start,
      TextCapitalization textCapitalization = TextCapitalization.sentences,
      TextInputAction textInputAction = TextInputAction.next,
      bool expands = false,
      VoidCallback onEditingComplete,
      ValueChanged<String> onSubmitted,
    }) {
  var formSkinBloc = Provider.of<FormSkinBloc>(context);
  var androidBuilder;
  var iosBuilder;

  Color labelColor;
  Color hintColor;
  Color textEditColor;
  if (bloc.enabled) {
    labelColor = formSkinBloc.textRowInputDecorationLabelTextStyle.color;
    hintColor = formSkinBloc.textRowInputDecorationHintTextStyle.color;
    textEditColor = formSkinBloc.textRowEditTextStyle.color;
  } else {
    labelColor = Colors.grey;
    hintColor = Colors.grey;
    textEditColor = Colors.grey;
  }

  androidBuilder = (_) {
    return MaterialTextFieldData(
        enabled: bloc.enabled,
        enableInteractiveSelection: true,
        style: formSkinBloc.textRowEditTextStyle.copyWith(color: textEditColor),
        decoration: InputDecoration(
            enabled: bloc.enabled,
            labelText: labelText,
            hintText: hint,
            labelStyle: formSkinBloc.textRowInputDecorationLabelTextStyle
                .copyWith(color: labelColor),
            hintStyle: formSkinBloc.textRowInputDecorationHintTextStyle
                .copyWith(color: hintColor)));
  };

  iosBuilder = (_) => CupertinoTextFieldData(
      enabled: bloc.enabled,
      placeholder: hint,
      padding: EdgeInsets.all(8),
      style: formSkinBloc.textRowEditTextStyle.copyWith(color: textEditColor),
      prefixMode: OverlayVisibilityMode.notEditing,
      prefix: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          labelText,
          style: formSkinBloc.textRowInputDecorationLabelTextStyle
              .copyWith(color: labelColor),
        ),
      ),
      placeholderStyle: formSkinBloc.textRowInputDecorationHintTextStyle
          .copyWith(color: hintColor));

  var platformTextField = PlatformTextField(
      keyboardType: keyboardType,
      focusNode: bloc.focusNode,
      inputFormatters: formatters,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      autocorrect: autocorrect,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      expands: expands,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      android: androidBuilder,
      ios: iosBuilder,
      controller: controller,
      onChanged: (newValue) {
        bloc.onNewValue(newValue);
      });
  return platformTextField;
}
