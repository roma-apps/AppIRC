import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_edit_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';
import 'package:flutter_appirc/widgets/lounge_preferences_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoungeEditConnectionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoungeEditConnectionPageState();
  }
}

class LoungeEditConnectionPageState extends State<LoungeEditConnectionPage> {
  @override
  Widget build(BuildContext context) {
    final LoungeService lounge = Provider.of<LoungeService>(context);
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    var loungePreferences = loungePreferencesBloc.getPreferenceOrDefault();
    var loungeConnectionBloc = LoungeEditConnectionBloc(
        socketIOManager: lounge.socketIOManager,
        preferencesBloc: loungePreferencesBloc,
        newLoungePreferences: loungePreferences);

    var appLocalizations = AppLocalizations.of(context);
    return SafeArea(
      child: Provider<LoungeEditConnectionBloc>(
        bloc: loungeConnectionBloc,
        child: PlatformScaffold(
          iosContentBottomPadding: true,
          iosContentPadding: true,

          appBar: PlatformAppBar(
            title: Text(appLocalizations.tr('lounge.connection.edit.title')),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Provider<LoungeEditConnectionBloc>(
                  bloc: loungeConnectionBloc,
                  child: Provider<LoungeConnectionBloc>(
                      bloc: loungeConnectionBloc,
                      child: LoungePreferencesWidget(loungePreferences)),
                ),
                Provider<AsyncOperationBloc>(
                  bloc: loungeConnectionBloc,
                  child: ButtonLoadingWidget(
                      child: Text(
                          appLocalizations.tr('lounge.connection.edit.change'),
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        var isPreferencesValid = false;
                        var exception;
                        try {
                          isPreferencesValid =
                          await loungeConnectionBloc.checkPreferences();
                        } on Exception catch (e) {
                          exception = e;
                        }

                        if (isPreferencesValid) {
                          showPlatformDialog(
                              androidBarrierDismissible: true,
                              context: context,
                              builder: (_) =>
                                  PlatformAlertDialog(
                                    title: Text(appLocalizations.tr(
                                        "lounge.connection.edit.confirm_dialog.title")),
                                    content: Text(appLocalizations.tr(
                                        "lounge.connection.edit.confirm_dialog.content")),
                                    actions: <Widget>[
                                      PlatformDialogAction(
                                        child: Text(appLocalizations.tr(
                                            "lounge.connection.edit.confirm_dialog.save_reload")),
                                        onPressed: () async {
                                          lounge.disconnect();

                                          loungePreferencesBloc
                                              .setNewPreferenceValue(
                                              loungeConnectionBloc
                                                  .newLoungePreferences);
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
                                  buildLoungeConnectionErrorAlertDialog(
                                      context, exception));
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
