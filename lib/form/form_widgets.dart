import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/form/form_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
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
    String label,
    String hint,
    IconData iconData,
    FormValueFieldBloc<String> bloc,
    TextEditingController controller) {
  var formSkinBloc = Provider.of<FormSkinBloc>(context);

  if (bloc.visible) {
    var androidBuilder;
    var iosBuilder;

    if (bloc.enabled) {
      androidBuilder = (_) => MaterialTextFieldData(
          enabled: bloc.enabled,
          style: formSkinBloc.textRowEditTextStyle,
          decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: formSkinBloc.textRowInputDecorationLabelTextStyle,
              hintStyle: formSkinBloc.textRowInputDecorationHintTextStyle));

      iosBuilder = (_) => CupertinoTextFieldData(
            enabled: bloc.enabled,
            padding: EdgeInsets.all(8),
            style: formSkinBloc.textRowEditTextStyle,
            placeholder: hint,
        prefixMode: OverlayVisibilityMode.notEditing,
            prefix: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(label,
                  style: formSkinBloc.textRowInputDecorationLabelTextStyle
                      .copyWith(color: Colors.grey)),
            ),
            placeholderStyle: formSkinBloc.textRowInputDecorationHintTextStyle
                .copyWith(color: Colors.grey),
          );
    } else {
      androidBuilder = (_) => MaterialTextFieldData(
          enabled: bloc.enabled,
          style: formSkinBloc.textRowEditTextStyle.copyWith(color: Colors.grey),
          decoration: InputDecoration(
              enabled: bloc.enabled,

              labelText: label,
              hintText: hint,
              labelStyle: formSkinBloc.textRowInputDecorationLabelTextStyle
                  .copyWith(color: Colors.grey),
              hintStyle: formSkinBloc.textRowInputDecorationHintTextStyle
                  .copyWith(color: Colors.grey)));

      iosBuilder = (_) => CupertinoTextFieldData(
          enabled: bloc.enabled,
          placeholder: hint,
          padding: EdgeInsets.all(8),
          style: formSkinBloc.textRowEditTextStyle.copyWith(color: Colors.grey),
          prefixMode: OverlayVisibilityMode.notEditing,
          prefix: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: formSkinBloc.textRowInputDecorationLabelTextStyle
                  .copyWith(color: Colors.grey),
            ),
          ),
          placeholderStyle: formSkinBloc.textRowInputDecorationHintTextStyle
              .copyWith(color: Colors.grey));
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(iconData),
            ),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: PlatformTextField(

                        textAlign: TextAlign.start,
                        android: androidBuilder,
                        ios: iosBuilder,
                        controller: controller,
                        onChanged: (newValue) {
                          bloc.onNewValue(newValue);
                        }))),
          ],
        ),
        StreamBuilder<ValidationError>(
            stream: bloc.errorStream,
            builder: (context, snapshot) {
              var error = snapshot.data;
              var isDataValid = error == null;

              var notValidWidget = isDataValid
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(error.getDescription(context)));

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
