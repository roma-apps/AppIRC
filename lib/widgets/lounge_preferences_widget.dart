import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/lounge_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'form_widgets.dart';

var _logger = MyLogger(logTag: "LoungePreferencesWidget", enabled: true);

class LoungePreferencesWidget extends StatefulWidget {

  final LoungePreferences preferences;


  LoungePreferencesWidget(this.preferences);

  @override
  State<StatefulWidget> createState() => LoungePreferencesWidgetState(preferences);
}

class LoungePreferencesWidgetState extends State<LoungePreferencesWidget> {


  final LoungePreferences preferences;


  TextEditingController _hostController;
  LoungePreferencesWidgetState(this.preferences) {
    _hostController = TextEditingController(text:preferences.host);
  }

  @override
  Widget build(BuildContext context) {
    final LoungeConnectionBloc loungeConnectionBloc =
        Provider.of<LoungeConnectionBloc>(context);


    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('lounge.connection.settings')),
        buildFormTextRow(
            appLocalizations.tr('lounge.connection.host'),
            Icons.cloud,
            _hostController,
            (value) {
          _fillPreferencesFromUI(loungeConnectionBloc);
        }),
      ],
    );
  }

  void _fillPreferencesFromUI(LoungeNewConnectionBloc lounge) {
    lounge.newLoungePreferences = LoungePreferences(host: _hostController.text);
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

Future<bool> connectToLounge(
    BuildContext context, LoungeNewConnectionBloc loungeConnectionBloc) async {
  _logger.i(() => "Connecting to $loungeConnectionBloc.");

  bool connected;
  Exception exception;
  try {
    connected = await loungeConnectionBloc.connect();
  } on Exception catch (e) {
    connected = false;
    exception = e;
  }
  _logger.i(() => "Connected = $connected ");

  if (!connected) {
    showPlatformDialog(
      androidBarrierDismissible: true,
      context: context,
      builder: (_) => buildLoungeConnectionErrorAlertDialog(context, exception),
    );
  }
  return connected;
}
