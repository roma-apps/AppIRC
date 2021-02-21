import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Widget buildFormBooleanRow(
    {@required BuildContext context,
    @required String title,
    @required FormValueFieldBloc<bool> bloc}) {
  if (bloc.visible) {
    var appIrcUiTextTheme = IAppIrcUiTextTheme.of(context);
    var appIrcUiColorTheme = IAppIrcUiColorTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: appIrcUiTextTheme.mediumDarkGrey,
          ),
          StreamBuilder<bool>(
            stream: bloc.valueStream,
            builder: (context, snapshot) {
              var changed = bloc.enabled ? bloc.onNewValue : null;
              return PlatformSwitch(
                activeColor: appIrcUiColorTheme.primary,
                value: snapshot.data != false,
                onChanged: changed,
              );
            },
          ),
        ],
      ),
    );
  } else {
    return const SizedBox.shrink();
  }
}
