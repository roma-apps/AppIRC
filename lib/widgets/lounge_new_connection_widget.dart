import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/helpers/logger.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/lounge_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'form_widgets.dart';

var _logger = MyLogger(logTag: "LoungeNewConnectionWidget", enabled: true);

class LoungeNewConnectionWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoungeNewConnectionState();
}

class LoungeNewConnectionState extends State<LoungeNewConnectionWidget> {
  final _hostController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final LoungeNewConnectionBloc lounge =
        Provider.of<LoungeNewConnectionBloc>(context);

    _hostController.text = lounge.newLoungePreferences.host;
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTitle(
            context, appLocalizations.tr('lounge_connection.settings')),
        buidFormTextRow(
            appLocalizations.tr('lounge_connection.host'), _hostController,
            (value) {
          _fillPreferencesFromUI(lounge);
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
              .tr('lounge_connection.dialog.already_connected.title');
          content = appLocalizations
              .tr('lounge_connection.dialog.already_connected.content');
          break;
        case ConnectionTimeoutLoungeException:
          title = appLocalizations
              .tr('lounge_connection.dialog.connection_timeout.title');
          content = appLocalizations
              .tr('lounge_connection.dialog.connection_timeout.content');
          break;
        case ConnectionErrorLoungeException:
          var connectionErrorException =
              connectionException as ConnectionErrorLoungeException;
          title = appLocalizations
              .tr('lounge_connection.dialog.connection_error.title');
          content = appLocalizations.tr(
              'lounge_connection.dialog.connection_error.content',
              args: [connectionErrorException.data]);
          break;
        default:
          title = appLocalizations
              .tr('lounge_connection.dialog.connection_error.title');
          content = appLocalizations.tr(
              'lounge_connection.dialog.connection_error.content',
              args: [e.toString()]);
      }
    } else {
      title = appLocalizations
          .tr('lounge_connection.dialog.connection_error.title');
      content = appLocalizations.tr(
          'lounge_connection.dialog.connection_error.content',
          args: [e.toString()]);
    }
  } else {
    title =
        appLocalizations.tr('lounge_connection.dialog.connection_error.title');
    content = appLocalizations
        .tr('lounge_connection.dialog.connection_error.content');
  }

  return PlatformAlertDialog(title: Text(title), content: Text(content));
}

Future<bool> connectToLounge(
    BuildContext context, LoungeNewConnectionBloc loungeConnectionBloc) async {
  _logger.i(() => "Connecting to $loungeConnectionBloc.");

  bool connected = true;
  Exception exception;
  try {
    await loungeConnectionBloc.connect();
  } on Exception catch (e) {
    connected = false;
    exception = e;
  }
  _logger.i(() => "Connected = $connected ");

  if (!connected) {
    showPlatformDialog(
      context: context,
      builder: (_) => buildLoungeConnectionErrorAlertDialog(context, exception),
    );
  }
  return connected;
}
