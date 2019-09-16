import 'package:flutter/material.dart' show Divider;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/form/form_field_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef void BooleanCallback(bool);

buildFormTitle(BuildContext context, String title) => Padding(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: UISkin.of(context).appSkin.formRowLabelTextStyle,
          ),
          Divider()
        ],
      ),
      padding: const EdgeInsets.all(4.0),
    );

buildFormTextRow(String title, String notValidDataDescription, IconData iconData, FormTextFieldBloc bloc) =>
    StreamBuilder<bool>(
        stream: bloc.dataValidStream,
        builder: (context, snapshot) {
          var isDataValid = snapshot.data;
          var boxDecoration = isDataValid ? BoxDecoration(color: Colors.redAccent) : null;
          var notValidWidget = isDataValid ? Container() : Text(notValidDataDescription);
          var body = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(iconData),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PlatformTextField(
                      android: (_) => MaterialTextFieldData(
                          decoration: InputDecoration(
                              hintText: title,
                              hintStyle: TextStyle(color: Colors.grey))),
                      ios: (_) => CupertinoTextFieldData(placeholder: title),
                      controller: bloc.textEditingController),
                ),
              ),
              notValidWidget
            ],
          );
          return Container(
            decoration: boxDecoration,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: body,
            ),
          );
        });

buildFormBooleanRow(String title, bool startValue, BooleanCallback callback) =>
    Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(title),
          PlatformSwitch(
            value: startValue,
            onChanged: callback,
          ),
        ],
      ),
    );
