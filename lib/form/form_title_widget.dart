import 'package:flutter/material.dart' show Divider;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/form_title_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';

Widget buildFormTitle(
    {@required BuildContext context, @required String title}) {
  var formTitleSkinBloc = Provider.of<FormTitleSkinBloc>(context);

  return Padding(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: formTitleSkinBloc.titleTextStyle,
        ),
        Divider()
      ],
    ),
    padding: const EdgeInsets.all(4.0),
  );
}
