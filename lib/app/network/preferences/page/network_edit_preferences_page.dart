import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_preferences_page.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/dialog/async/async_dialog_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';

class EditNetworkPreferencesPage extends NetworkPreferencesPage {
  EditNetworkPreferencesPage(
      {@required BuildContext context,
      @required NetworkPreferences startValues,
      @required bool serverPreferencesEnabled,
      @required bool serverPreferencesVisible})
      : super.name(
          titleText: S.of(context).irc_connection_edit_title,
          startValues: startValues,
          isNeedShowChannels: false,
          isNeedShowCommands: true,
          serverPreferencesEnabled: serverPreferencesEnabled,
          serverPreferencesVisible: serverPreferencesVisible,
          buttonText: S.of(context).irc_connection_edit_action_save,
        );

  @override
  Future<AsyncDialogResult<RequestResult<Network>>> successCallback(
      BuildContext context, NetworkPreferences preferences) async {
    final NetworkBloc networkBloc = NetworkBloc.of(context);

    var result = await doAsyncOperationWithDialog(
      context: context,
      asyncCode: () async {
        return await networkBloc.editNetworkSettings(preferences);
      },
      cancelable: true,
    );

    if (result.success) {
      Navigator.pop(context);
    }

    return result;
  }
}
