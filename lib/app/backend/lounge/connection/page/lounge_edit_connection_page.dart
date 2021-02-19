import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_connection_page.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

MyLogger _logger =
    MyLogger(logTag: "lounge_edit_connection_page.dart", enabled: true);

class EditLoungeConnectionPage extends LoungeConnectionPage {
  EditLoungeConnectionPage() : super();

  @override
  onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences) async {

    _logger.d(() => "build");
    showPlatformDialog(
        androidBarrierDismissible: true,
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text(tr("lounge.preferences.edit.dialog.confirm.title")),
              content: Text(tr("lounge.preferences.edit.dialog.confirm.content")),
              actions: <Widget>[
                PlatformDialogAction(
                  child: Text(tr("lounge.preferences.edit.dialog.confirm.action"
                          ".save_reload")),
                  onPressed: () async {

                    MessageManagerBloc managerBloc = Provider.of(context);
                    await managerBloc.clearAllMessages();

                    _dismissDialog(context);
                    _goToPreviousPage(context);
                    _saveNewPreferenceValue(context, preferences);
                  },
                ),
                PlatformDialogAction(
                  child: Text(tr(
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
