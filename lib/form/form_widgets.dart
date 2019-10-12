import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/form/form_skin_bloc.dart';
import 'package:flutter_appirc/platform_widgets/platform_aware_text_field.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef void BooleanCallback(bool);

buildFormTitle(BuildContext context, String title) {
  var formSkinBloc = Provider.of<FormSkinBloc>(context);

  return Padding(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: formSkinBloc.titleTextStyle,
        ),
        Divider()
      ],
    ),
    padding: const EdgeInsets.all(4.0),
  );
}

buildFormTextRow(
    BuildContext context,
    FormValueFieldBloc<String> bloc,
    TextEditingController controller,
    IconData labelIcon,
    String labelText,
    String hint,
    {List<TextInputFormatter> formatters,
    TextInputType keyboardType = TextInputType.text,
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
    FormValueFieldBloc nextBloc}) {
  if (textInputAction == TextInputAction.next) {
    assert(nextBloc != null);
    assert(onSubmitted == null);
    onSubmitted = (_) {
      FocusScope.of(context).requestFocus(nextBloc.focusNode);
    };
  }

  if (bloc.visible) {
    PlatformTextField platformTextField = buildTextField(
        context, bloc, controller, labelText, hint,
        keyboardType: keyboardType,
        formatters: formatters,
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
        onSubmitted: onSubmitted);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(labelIcon),
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
                      child: Text(error.getDescription(context),
                          style: TextStyle(
                              color: AppSkinBloc.of(context)
                                  .appSkinTheme
                                  .textColor)));

              return notValidWidget;
            }),
      ],
    );
  } else {
    return _buildEmptyWidget();
  }
}


SizedBox _buildEmptyWidget() => SizedBox.shrink();

buildFormBooleanRow(
    BuildContext context, String title, FormValueFieldBloc<bool> bloc) {
  if (bloc.visible) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: Provider.of<FormSkinBloc>(context).booleanRowLabelTextStyle,
          ),
          StreamBuilder<bool>(
              stream: bloc.valueStream,
              builder: (context, snapshot) {
                var changed = bloc.enabled ? bloc.onNewValue : null;
                return PlatformSwitch(
                  activeColor:
                      Provider.of<FormSkinBloc>(context).switchActiveColor,
                  value: snapshot.data != false,
                  onChanged: changed,
                );
              }),
        ],
      ),
    );
  } else {
    return _buildEmptyWidget();
  }
}
