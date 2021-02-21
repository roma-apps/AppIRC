import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_connection_page.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

MyLogger _logger =
    MyLogger(logTag: "lounge_edit_connection_page.dart", enabled: true);

class EditLoungeConnectionPage extends LoungeConnectionPage {
  EditLoungeConnectionPage() : super();

  @override
  void onSuccessTestConnectionWithGivenPreferences(
      BuildContext context, LoungePreferences preferences) async {
    _logger.d(() => "build");
    await showPlatformDialog(
      androidBarrierDismissible: true,
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text(
          S.of(context).lounge_preferences_edit_dialog_confirm_title,
        ),
        content: Text(
          S.of(context).lounge_preferences_edit_dialog_confirm_content,
        ),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text(
              S
                  .of(context)
                  .lounge_preferences_edit_dialog_confirm_action_save_reload,
            ),
            onPressed: () async {
              var managerBloc = Provider.of<MessageManagerBloc>(context);
              await managerBloc.clearAllMessages();

              _dismissDialog(context);
              _goToPreviousPage(context);
              _saveNewPreferenceValue(context, preferences);
            },
          ),
          PlatformDialogAction(
            child: Text(
              S
                  .of(context)
                  .lounge_preferences_edit_dialog_confirm_action_cancel,
            ),
            onPressed: () async {
              _dismissDialog(context);
            },
          )
        ],
      ),
    );
  }

  void _saveNewPreferenceValue(
      BuildContext context, LoungePreferences preferences) {
    var currentAuthInstanceBloc = ICurrentAuthInstanceBloc.of(context);

    currentAuthInstanceBloc.changeCurrentInstance(preferences);
  }

  void _dismissDialog(BuildContext context) {
    Navigator.pop(context);
  }

  void _goToPreviousPage(BuildContext context) {
    Navigator.pop(context);
  }
}
