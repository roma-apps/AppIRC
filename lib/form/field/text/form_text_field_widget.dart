import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_skin_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation_widgets.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_text_field.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Widget buildFormTextField(
    {@required BuildContext context,
    @required FormValueFieldBloc<String> bloc,
    @required TextEditingController controller,
    @required String label,
    @required String hint,
    List<TextInputFormatter> formatters,
    TextInputType keyboardType,
    int maxLength,
    int minLines,
    int maxLines = 1,
    bool obscureText,
    bool autoCorrect,
    TextAlign textAlign,
    TextCapitalization textCapitalization,
    TextInputAction textInputAction,
    bool expands,
    VoidCallback onEditingComplete,
    ValueChanged<String> onSubmitted,
    FormValueFieldBloc nextBloc}) {
  FormTextFieldSkinBloc skinBloc = Provider.of(context);

  return buildPlatformTextField(
    context: context,
    controller: controller,
    label: label,
    hint: hint,
    onChanged: bloc.onNewValue,
    focusNode: bloc.focusNode,
    keyboardType: keyboardType,
    formatters: formatters,
    maxLength: maxLength,
    minLines: minLines,
    maxLines: maxLines,
    obscureText: obscureText,
    autoCorrect: autoCorrect,
    textAlign: textAlign,
    textCapitalization: textCapitalization,
    textInputAction: textInputAction,
    expands: expands,
    onEditingComplete: onEditingComplete,
    onSubmitted: onSubmitted,
    labelStyle: skinBloc.labelStyle,
    hintStyle: skinBloc.hintStyle,
    editStyle: skinBloc.editStyle,
    disabledLabelStyle: skinBloc.disabledLabelStyle,
    disabledHintStyle: skinBloc.disabledHintStyle,
    disabledEditStyle: skinBloc.disabledEditStyle,
  );
}

Widget buildFormTextRow({
  @required BuildContext context,
  @required FormValueFieldBloc<String> bloc,
  @required TextEditingController controller,
  @required IconData icon,
  @required String label,
  @required String hint,
  List<TextInputFormatter> formatters,
  TextInputType keyboardType = TextInputType.text,
  int maxLength,
  int minLines,
  int maxLines = 1,
  bool obscureText,
  bool autoCorrect,
  TextAlign textAlign,
  TextCapitalization textCapitalization,
  TextInputAction textInputAction,
  bool expands,
  VoidCallback onEditingComplete,
  ValueChanged<String> onSubmitted,
  FormValueFieldBloc nextBloc,
}) {
  if (textInputAction == TextInputAction.next) {
    assert(nextBloc != null);
    assert(onSubmitted == null);
    onSubmitted = (_) {
      FocusScope.of(context).requestFocus(nextBloc.focusNode);
    };
  }

  if (textInputAction == TextInputAction.done) {
    assert(onSubmitted == null);
    onSubmitted = (_) {
      FocusScope.of(context).requestFocus(FocusNode());
    };
  }

  if (bloc.visible) {
    FormTextFieldSkinBloc formTextFieldSkinBloc = Provider.of(context);

    PlatformTextField platformTextField = buildFormTextField(
      context: context,
      controller: controller,
      bloc: bloc,
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      formatters: formatters,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      autoCorrect: autoCorrect,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      expands: expands,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
    );
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(icon),
            ),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: platformTextField)),
          ],
        ),
        StreamBuilder<ValidationError>(
            stream: bloc.errorStream,
            initialData: bloc.error,
            builder: (context, snapshot) {
              var error = snapshot.data;
              var isDataValid = error == null;

              var notValidWidget = isDataValid
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                          createDefaultTextValidationErrorDescription(
                              context, error),
                          style: formTextFieldSkinBloc.errorStyle));

              return notValidWidget;
            }),
      ],
    );
  } else {
    return SizedBox.shrink();
  }
}
