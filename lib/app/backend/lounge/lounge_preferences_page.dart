import 'package:adhara_socket_io/manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_widget.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef PreferencesActionCallback = void Function(
    BuildContext context, LoungeConnectionPreferences preferences);

class NewLoungePreferencesPage extends LoungePreferencesPage {
  NewLoungePreferencesPage(LoungeConnectionPreferences startPreferencesValues)
      : super(startPreferencesValues, (context, preferences) async {
    return await _newPreferencesCallback(
        context, preferences, startPreferencesValues);
  });
}

class EditLoungePreferencesPage extends LoungePreferencesPage {
  EditLoungePreferencesPage(LoungeConnectionPreferences startPreferencesValues)
      : super(startPreferencesValues, (context, preferences) async {
    return await _editPreferencesCallback(
        context, preferences, startPreferencesValues);
  });
}

void savePreferences(BuildContext context,
    LoungeConnectionPreferences startPreferencesValues) {
  Provider.of<LoungePreferencesBloc>(context).setValue(startPreferencesValues);
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

    loungePreferencesFormBloc = LoungePreferencesFormBloc(startPreferencesValues);
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
                    stream: loungePreferencesFormBloc
                        .dataValidStream,
                    builder: (context, snapshot) {
                      var error = snapshot.data;
                      var isDataValid = error != false;

                      Function pressed;

                      if(isDataValid) {
                        pressed =  () =>
                            actionCallback(
                                context,
                                Provider.of<LoungePreferencesFormBloc>(context)
                                    .extractData());
                      }

                      return PlatformButton(
                        color: Colors.redAccent,
                        disabledColor: Colors.grey,
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


Future _editPreferencesCallback(BuildContext context,
    LoungeConnectionPreferences preferences,
    LoungeConnectionPreferences startPreferencesValues) async =>
    await tryConnect(context, preferences, (connected) async {
      if (connected) {
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
                      child: Text(appLocalizations
                          .tr(
                          "lounge.connection.edit.confirm_dialog.save_reload")),
                      onPressed: () async {
                        savePreferences(context, startPreferencesValues);
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
      }
    }, (exception) async {
      showPlatformDialog(
          androidBarrierDismissible: true,
          context: context,
          builder: (_) =>
              buildLoungeConnectionErrorAlertDialog(context, exception));
    });

Future _newPreferencesCallback(BuildContext context,
    LoungeConnectionPreferences preferences,
    LoungeConnectionPreferences startPreferencesValues) async =>
    await tryConnect(context, preferences, (connected) async {
      if (connected) {
        savePreferences(context, startPreferencesValues);
      }
    }, (exception) async  {
      showPlatformDialog(
        androidBarrierDismissible: true,
        context: context,
        builder: (_) =>
            buildLoungeConnectionErrorAlertDialog(context, exception),
      );
    });

Future tryConnect(BuildContext context, LoungeConnectionPreferences preferences,
    Future connectCallback(bool connected),
    Future exceptionCallback(Exception e)) async =>
    await doAsyncOperationWithDialog(context, () async {
      var lounge = LoungeBackendService(SocketIOManager(), preferences);

      bool connected;

      Exception exception;
      try {
        var requestResult = await lounge.tryConnectWithDifferentPreferences(preferences);
        connected = requestResult.result;
      } on Exception catch (e) {
        connected = false;
        exception = e;

      }


      if (exception != null) {
        exceptionCallback(exception);
      } else {
        connectCallback(connected);
      }


    });
