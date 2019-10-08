import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_form_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "LoungePreferencesPage", enabled: true);

typedef PreferencesActionCallback = void Function(
    BuildContext context, LoungePreferences preferences);

class NewLoungePreferencesPage extends LoungePreferencesPage {
  NewLoungePreferencesPage(LoungePreferences startPreferences)
      : super(startPreferences);

  @override
  successCallback(BuildContext context, LoungePreferences preferences) async {
    Provider.of<LoungePreferencesBloc>(context).setValue(preferences);
  }
}

class EditLoungePreferencesPage extends LoungePreferencesPage {
  EditLoungePreferencesPage(LoungePreferences startPreferences)
      : super(startPreferences);

  @override
  successCallback(BuildContext context, LoungePreferences preferences) async {
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    var appLocalizations = AppLocalizations.of(context);
    showPlatformDialog(
        androidBarrierDismissible: true,
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text(appLocalizations.tr(
                  "lounge.preferences.edit.dialog.confirm.title")),
              content: Text(appLocalizations.tr(
                  "lounge.preferences.edit.dialog.confirm.content")),
              actions: <Widget>[
                PlatformDialogAction(
                  child: Text(appLocalizations.tr(
                      "lounge.preferences.edit.dialog.confirm.save_reload")),
                  onPressed: () async {
                    // exit dialog
                    Navigator.pop(context);
                    // exit edit page
                    Navigator.pop(context);
                    loungePreferencesBloc.setValue(preferences);
                  },
                ),
                PlatformDialogAction(
                  child: Text(appLocalizations.tr(
                      "lounge.preferences.edit.dialog.confirm.cancel")),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }
}

abstract class LoungePreferencesPage extends StatefulWidget {
  final LoungePreferences startPreferences;

  successCallback(BuildContext context, LoungePreferences preferences);

  LoungePreferencesPage(this.startPreferences);

  @override
  State<StatefulWidget> createState() {
    return LoungePreferencesPageState(startPreferences, successCallback);
  }
}

class LoungePreferencesPageState extends State<LoungePreferencesPage> {
  final PreferencesActionCallback actionCallback;
  final LoungePreferences startPreferencesValues;

  LoungePreferencesFormBloc preferencesFormBloc;

  LoungePreferencesPageState(this.startPreferencesValues, this.actionCallback) {
    preferencesFormBloc = LoungePreferencesFormBloc(startPreferencesValues);
  }

  @override
  void dispose() {
    super.dispose();
    preferencesFormBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title:
            Text(AppLocalizations.of(context).tr('lounge.preferences.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider<LoungePreferencesFormBloc>(
            providable: preferencesFormBloc,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: LoungePreferencesFormWidget(
                      startPreferencesValues,
                      actionCallback,
                      AppLocalizations.of(context)
                          .tr('lounge.preferences.connect')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
