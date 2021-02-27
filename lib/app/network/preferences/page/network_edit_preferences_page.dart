import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_model.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_preferences_page.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/dialog/async/async_dialog_model.dart';

class EditNetworkPreferencesPage extends NetworkPreferencesPage {
  EditNetworkPreferencesPage({
    @required NetworkPreferences startValues,
    @required bool serverPreferencesEnabled,
    @required bool serverPreferencesVisible,
    @required String titleText,
    @required String buttonText,
  }) : super(
          startValues: startValues,
          isNeedShowChannels: false,
          isNeedShowCommands: true,
          serverPreferencesEnabled: serverPreferencesEnabled,
          serverPreferencesVisible: serverPreferencesVisible,
          titleText: titleText,
          buttonText: buttonText,
        );

  @override
  Future<AsyncDialogResult<RequestResult<Network>>> successCallback(
    BuildContext context,
    NetworkPreferences preferences,
  ) async {
    final NetworkBloc networkBloc = NetworkBloc.of(
      context,
      listen: false,
    );

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
