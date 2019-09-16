import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_widget.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/async/button_loading_widget.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef PreferencesActionCallback = void Function(
    BuildContext context, LoungePreferences preferences);

class LoungeNewConnectionPage extends LoungeConnectionPage {
  LoungeNewConnectionPage(LoungePreferences startPreferencesValues)
      : super(startPreferencesValues, (context, preferences) async {
          var lounge =
              LoungeConnectionBloc(Provider.of<LoungeBackendService>(context));

          var connected;

          Exception exception;
          try {
            connected = await lounge.tryConnect(preferences);
          } on Exception catch (e) {
            connected = false;
            exception = e;
          }

          if (!connected) {
            showPlatformDialog(
              androidBarrierDismissible: true,
              context: context,
              builder: (_) =>
                  buildLoungeConnectionErrorAlertDialog(context, exception),
            );
          }

          savePreferences(context, startPreferencesValues);
        });
}

class LoungeEditConnectionPage extends LoungeConnectionPage {
  LoungeEditConnectionPage(LoungePreferences startPreferencesValues)
      : super(startPreferencesValues, (context, preferences) async {
          var lounge =
              LoungeConnectionBloc(Provider.of<LoungeBackendService>(context));

          var appLocalizations = AppLocalizations.of(context);

          var connected;
          Exception exception;
          try {
            connected = await lounge.tryConnect(preferences);
          } on Exception catch (e) {
            connected = false;
            exception = e;
          }

          if (connected) {
            showPlatformDialog(
                androidBarrierDismissible: true,
                context: context,
                builder: (_) => PlatformAlertDialog(
                      title: Text(appLocalizations
                          .tr("lounge.connection.edit.confirm_dialog.title")),
                      content: Text(appLocalizations
                          .tr("lounge.connection.edit.confirm_dialog.content")),
                      actions: <Widget>[
                        PlatformDialogAction(
                          child: Text(appLocalizations.tr(
                              "lounge.connection.edit.confirm_dialog.save_reload")),
                          onPressed: () async {
                            savePreferences(context, startPreferencesValues);
                          },
                        ),
                        PlatformDialogAction(
                          child: Text(appLocalizations.tr(
                              "lounge.connection.edit.confirm_dialog.cancel")),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ));
          } else {
            showPlatformDialog(
                androidBarrierDismissible: true,
                context: context,
                builder: (_) =>
                    buildLoungeConnectionErrorAlertDialog(context, exception));
          }
        });
}

void savePreferences(
    BuildContext context, LoungePreferences startPreferencesValues) {
  Provider.of<LoungePreferencesBloc>(context).setValue(startPreferencesValues);
}

class LoungeConnectionPage extends StatefulWidget {
  final LoungePreferences startPreferencesValues;
  final PreferencesActionCallback actionCallback;

  LoungeConnectionPage(this.startPreferencesValues, this.actionCallback);

  @override
  State<StatefulWidget> createState() {
    return LoungeConnectionPageState(startPreferencesValues, actionCallback);
  }
}

class LoungeConnectionPageState extends State<LoungeConnectionPage> {
  final PreferencesActionCallback actionCallback;
  final LoungePreferences startPreferencesValues;

  LoungeConnectionPageState(this.startPreferencesValues, this.actionCallback);

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
            bloc: LoungePreferencesFormBloc(startPreferencesValues),
            child: Column(
              children: <Widget>[
                LoungePreferencesFormWidget(),
                StreamBuilder<bool>(
                    stream: Provider.of<LoungePreferencesFormBloc>(context)
                        .dataValidStream,
                    builder: (context, snapshot) {
                      var isDataValid = snapshot.data;
                      var pressed = isDataValid
                          ? () => () => actionCallback(
                              context,
                              Provider.of<LoungePreferencesFormBloc>(context)
                                  .extractData())
                          : null;
                      return Provider<AsyncOperationBloc>(
                        bloc: LoungeConnectionBloc(
                            Provider.of<LoungeBackendService>(context)),
                        child: ButtonLoadingWidget(
                          child: Text(
                              AppLocalizations.of(context)
                                  .tr('lounge.connection.new.connect'),
                              style: TextStyle(color: Colors.white)),
                          onPressed: pressed,
                        ),
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
