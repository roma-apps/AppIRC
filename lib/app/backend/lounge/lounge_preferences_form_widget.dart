import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/widgets/form_widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "LoungePreferencesWidget", enabled: true);

class LoungePreferencesFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoungePreferencesFormWidgetState();
}

class LoungePreferencesFormWidgetState
    extends State<LoungePreferencesFormWidget> {
  @override
  Widget build(BuildContext context) {
    var loungePreferencesFormBloc =
        Provider.of<LoungePreferencesFormBloc>(context);
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('lounge.connection.settings')),
        buildFormTextRow(
            appLocalizations.tr('lounge.connection.host'),
            appLocalizations.tr('form.empty_field_not_valid'),
            Icons.cloud,
            loungePreferencesFormBloc.hostFieldBloc)
      ],
    );
  }
}

PlatformAlertDialog buildLoungeConnectionErrorAlertDialog(
    BuildContext context, Exception e) {
  var appLocalizations = AppLocalizations.of(context);

  String title;
  String content;

  if (e != null) {
    var connectionException = e as ConnectionLoungeException;

    if (connectionException != null) {
      switch (connectionException.runtimeType) {
        case AlreadyConnectedLoungeException:
          title = appLocalizations
              .tr('lounge.connection.dialog.already_connected.title');
          content = appLocalizations
              .tr('lounge.connection.dialog.already_connected.content');
          break;
        case ConnectionTimeoutLoungeException:
          title = appLocalizations
              .tr('lounge.connection.dialog.connection_timeout.title');
          content = appLocalizations
              .tr('lounge.connection.dialog.connection_timeout.content');
          break;
        case ConnectionErrorLoungeException:
          var connectionErrorException =
              connectionException as ConnectionErrorLoungeException;
          title = appLocalizations
              .tr('lounge.connection.dialog.connection_error.title');
          content = appLocalizations.tr(
              'lounge.connection.dialog.connection_error.content',
              args: [connectionErrorException.data]);
          break;
        default:
          title = appLocalizations
              .tr('lounge.connection.dialog.connection_error.title');
          content = appLocalizations.tr(
              'lounge.connection.dialog.connection_error.content',
              args: [e.toString()]);
      }
    } else {
      title = appLocalizations
          .tr('lounge.connection.dialog.connection_error.title');
      content = appLocalizations.tr(
          'lounge.connection.dialog.connection_error.content',
          args: [e.toString()]);
    }
  } else {
    title =
        appLocalizations.tr('lounge.connection.dialog.connection_error.title');
    content = appLocalizations
        .tr('lounge.connection.dialog.connection_error.content');
  }

  return PlatformAlertDialog(title: Text(title), content: Text(content));
}
