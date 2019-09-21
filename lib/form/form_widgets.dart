import 'package:flutter/material.dart' show Divider;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef void BooleanCallback(bool);

buildFormTitle(BuildContext context, String title) => Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: UISkin.of(context).formRowLabelTextStyle,
          ),
          Divider()
        ],
      ),
      padding: const EdgeInsets.all(4.0),
    );

buildFormTextRow(String label, String hint, IconData iconData,
    FormValueFieldBloc<String> bloc, TextEditingController controller) {
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
              padding: const EdgeInsets.all(2.0),
              child: TextField(

                  controller: controller,
                  decoration: InputDecoration(
                      labelText: label,
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey)),
                  onChanged: (newValue) {
                    bloc.onNewValue(newValue);
                  }),

//            child: PlatformTextField(
//                android: (_) => MaterialTextFieldData(
//                    decoration: InputDecoration(
//                        labelText: label,
//                        hintText: hint,
//                        hintStyle: TextStyle(color: Colors.grey))),
//                ios: (_) =>
//                    CupertinoTextFieldData(placeholder: hint, prefix: Text(label)),
//                controller: controller,
//                onChanged: (newValue) {
//                  bloc.onNewValue(newValue);
//                }),
            ),
          ),
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
}

buildFormBooleanRow(String title, FormValueFieldBloc<bool> bloc) => Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(title),
          StreamBuilder<bool>(
              stream: bloc.valueStream,
              builder: (context, snapshot) {
                return PlatformSwitch(
                  value: snapshot.data != false,
                  onChanged: bloc.onNewValue,
                );
              }),
        ],
      ),
    );
