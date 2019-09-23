import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_widget.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "LoungePreferencesPage", enabled: true);

typedef PreferencesActionCallback = void Function(
    BuildContext context, LoungeConnectionPreferences preferences);

class NewLoungePreferencesPage extends LoungePreferencesPage {
  NewLoungePreferencesPage(LoungeConnectionPreferences startPreferencesValues)
      : super(startPreferencesValues, (context, preferences) async {
    return await _newPreferencesCallback(
        context, preferences);
  });
}

class EditLoungePreferencesPage extends LoungePreferencesPage {
  EditLoungePreferencesPage(LoungeConnectionPreferences startPreferencesValues)
      : super(startPreferencesValues, (context, preferences) async {
    return await _editPreferencesCallback(
        context, preferences);
  });
}


class LoungePreferencesPage extends StatefulWidget {
  final LoungeConnectionPreferences startPreferencesValues;
  final PreferencesActionCallback actionCallback;

  LoungePreferencesPage(this.startPreferencesValues, this.actionCallback);

  @override
  State<StatefulWidget> createState() {
    return LoungePreferencesPageState(startPreferencesValues, actionCallback);
  }
}

class LoungePreferencesPageState extends State<LoungePreferencesPage> {
  final PreferencesActionCallback actionCallback;
  final LoungeConnectionPreferences startPreferencesValues;
  LoungePreferencesFormBloc loungePreferencesFormBloc;

  LoungePreferencesPageState(this.startPreferencesValues, this.actionCallback);

  @override
  void initState() {
    super.initState();

    loungePreferencesFormBloc =
        LoungePreferencesFormBloc(startPreferencesValues);
  }

  @override
  void dispose() {
    super.dispose();
    loungePreferencesFormBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PlatformScaffold(
        iosContentBottomPadding: true,
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(
              AppLocalizations.of(context).tr('lounge.connection.new.title')),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider<LoungePreferencesFormBloc>(
            providable: loungePreferencesFormBloc,
            child: Column(
              children: <Widget>[
                LoungePreferencesFormWidget(startPreferencesValues),
                StreamBuilder<bool>(
                    stream: loungePreferencesFormBloc.dataValidStream,
                    builder: (context, snapshot) {
                      var error = snapshot.data;
                      var isDataValid = error != false;

                      Function pressed;

                      if (isDataValid) {
                        pressed = () =>
                            actionCallback(
                                context,
                                Provider.of<LoungePreferencesFormBloc>(context)
                                    .extractData());
                      }

                      return createSkinnedPlatformButton(
                        context,
                        child: Text(
                            AppLocalizations.of(context)
                                .tr('lounge.connection.new.connect'),
                            style: TextStyle(color: Colors.white)),
                        onPressed: pressed,
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}


_editPreferencesCallback(BuildContext context,
    LoungeConnectionPreferences preferences) async {

  try {
    bool connected = await doAsyncOperationWithDialog(
        context, () async => await tryConnect(context, preferences));

    if (connected) {
      var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);


      var appLocalizations = AppLocalizations.of(context);
      showPlatformDialog(
          androidBarrierDismissible: true,
          context: context,
          builder: (_) =>
              PlatformAlertDialog(
                title: Text(appLocalizations
                    .tr("lounge.connection.edit.confirm_dialog.title")),
                content: Text(appLocalizations
                    .tr("lounge.connection.edit.confirm_dialog.content")),
                actions: <Widget>[
                  PlatformDialogAction(
                    child: Text(appLocalizations.tr(
                        "lounge.connection.edit.confirm_dialog.save_reload")),
                    onPressed: () async {
                      // exit dialog
                      Navigator.pop(context);
                      // exit edit page
                      Navigator.pop(context);
                      loungePreferencesBloc.setValue(preferences);
                    },
                  ),
                  PlatformDialogAction(
                    child: Text(appLocalizations
                        .tr("lounge.connection.edit.confirm_dialog.cancel")),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  )
                ],
              ));
    } else {
      _showErrorDialog(context);
    }
  }  on PrivateLoungeNotSupportedException catch(e) {
    _showPrivateNotSupportedDialog(context, e);
  }  on InvalidConnectionResponseException catch(e) {
    _showInvalidResponseDialog(context, e);
  }
}

void _showErrorDialog(BuildContext context) {
  showPlatformDialog(
      androidBarrierDismissible: true,
      context: context,
      builder: (_) =>
          buildLoungeConnectionErrorAlertDialog(context));
}
void _showPrivateNotSupportedDialog(BuildContext context, PrivateLoungeNotSupportedException exception) {
  showPlatformDialog(
      androidBarrierDismissible: true,
      context: context,
      builder: (_) =>
          buildLoungeConnectionPrivateNotSupportedDialog(context, exception));
}
void _showInvalidResponseDialog(BuildContext context, InvalidConnectionResponseException exception) {
  showPlatformDialog(
      androidBarrierDismissible: true,
      context: context,
      builder: (_) =>
          buildLoungeConnectionInvalidResponseDialog(context, exception));
}

_newPreferencesCallback(BuildContext context,
    LoungeConnectionPreferences preferences) async {


  try {
    bool connected = await doAsyncOperationWithDialog(
        context, () async => await tryConnect(context, preferences));

    if (connected) {
      Provider.of<LoungePreferencesBloc>(context).setValue(preferences);
    } else {
      _showErrorDialog(context);
    }
  }  on PrivateLoungeNotSupportedException catch(e) {
    _showPrivateNotSupportedDialog(context, e);
  }  on InvalidConnectionResponseException catch(e) {
    _showInvalidResponseDialog(context, e);
  }
}

Future<bool> tryConnect(BuildContext context,
    LoungeConnectionPreferences preferences) async {


  var socketManagerProvider = Provider.of<SocketIOManagerProvider>(context);
  var lounge = LoungeBackendService(socketManagerProvider.manager, preferences);

  bool connected;

  var requestResult =
  await lounge.tryConnectWithDifferentPreferences(preferences);
  connected = requestResult.result;


  _logger.e(
          () => "tryConnect = $connected  $preferences");

  return connected;
}


PlatformAlertDialog buildLoungeConnectionErrorAlertDialog(
    BuildContext context) {

  var appLocalizations = AppLocalizations.of(context);

  String title =
  appLocalizations.tr('lounge.connection.dialog.connection_error.title');

  String content = appLocalizations.tr(
      'lounge.connection.dialog.connection_error.content');

  return PlatformAlertDialog(title: Text(title), content: Text(content));
}

PlatformAlertDialog buildLoungeConnectionInvalidResponseDialog(
    BuildContext context, InvalidConnectionResponseException exception) {
  var appLocalizations = AppLocalizations.of(context);

  String title =
      appLocalizations.tr('lounge.connection.dialog.invalid_response_error.title');

  String content = appLocalizations.tr(
      'lounge.connection.dialog.invalid_response_error.content');

  return PlatformAlertDialog(title: Text(title), content: Text(content));
}

PlatformAlertDialog buildLoungeConnectionPrivateNotSupportedDialog(
    BuildContext context, PrivateLoungeNotSupportedException  e) {
  var appLocalizations = AppLocalizations.of(context);

  String title =
  appLocalizations.tr('lounge.connection.dialog.private_not_supported_error.title');

  String content = appLocalizations.tr(
      'lounge.connection.dialog.private_not_supported_error.content');

  return PlatformAlertDialog(title: Text(title), content: Text(content));
}
