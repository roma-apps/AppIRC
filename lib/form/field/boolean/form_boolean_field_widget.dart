import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/form/field/boolean/form_boolean_field_skin_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Widget buildFormBooleanRow(
    {@required BuildContext context,
    @required String title,
    @required FormValueFieldBloc<bool> bloc}) {
  if (bloc.visible) {
    var booleanFieldSkinBloc = Provider.of<FormBooleanFieldSkinBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: booleanFieldSkinBloc.booleanRowLabelTextStyle,
          ),
          StreamBuilder<bool>(
              stream: bloc.valueStream,
              builder: (context, snapshot) {
                var changed = bloc.enabled ? bloc.onNewValue : null;
                return PlatformSwitch(
                  activeColor: booleanFieldSkinBloc.switchActiveColor,
                  value: snapshot.data != false,
                  onChanged: changed,
                );
              }),
        ],
      ),
    );
  } else {
    return SizedBox.shrink();
  }
}
