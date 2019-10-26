import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/page/lounge_preferences_page.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

MyLogger _logger =
    MyLogger(logTag: "lounge_edit_preferences_page.dart", enabled: true);

class EditLoungePreferencesPage extends LoungePreferencesPage {
  EditLoungePreferencesPage(LoungePreferences startPreferences)
      : super(startPreferences);

  @override
  onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences) async {
    var appLocalizations = AppLocalizations.of(context);

    _logger.d(() => "build");
    showPlatformDialog(
        androidBarrierDismissible: true,
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text(appLocalizations
                  .tr("lounge.preferences.edit.dialog.confirm.title")),
              content: Text(appLocalizations
                  .tr("lounge.preferences.edit.dialog.confirm.content")),
              actions: <Widget>[
                PlatformDialogAction(
                  child: Text(appLocalizations
                      .tr("lounge.preferences.edit.dialog.confirm.action"
                          ".save_reload")),
                  onPressed: () async {
                    _dismissDialog(context);
                    _goToPreviousPage(context);
                    _saveNewPreferenceValue(context, preferences);
                  },
                ),
                PlatformDialogAction(
                  child: Text(appLocalizations.tr(
                      "lounge.preferences.edit.dialog.confirm.action.cancel")),
                  onPressed: () async {
                    _dismissDialog(context);
                  },
                )
              ],
            ));
  }

  void _saveNewPreferenceValue(
      BuildContext context, LoungePreferences preferences) {
    var loungePreferencesBloc = Provider.of<LoungePreferencesBloc>(context);

    loungePreferencesBloc.setValue(preferences);
  }

  void _dismissDialog(BuildContext context) {
    Navigator.pop(context);
  }

  void _goToPreviousPage(BuildContext context) {
    Navigator.pop(context);
  }
}
