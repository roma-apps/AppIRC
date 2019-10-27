import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_preferences_page.dart';
import 'package:flutter_appirc/async/async_dialog.dart';

class EditChatNetworkPage extends ChatNetworkPreferencesPage {
  EditChatNetworkPage(
      {@required BuildContext context,
      @required ChatNetworkPreferences startValues,
      @required bool serverPreferencesEnabled,
      @required bool serverPreferencesVisible})
      : super.name(
            titleText:
                AppLocalizations.of(context).tr('irc.connection.edit.title'),
            startValues: startValues,
            isNeedShowChannels: false,
            isNeedShowCommands: true,
            serverPreferencesEnabled: serverPreferencesEnabled,
            serverPreferencesVisible: serverPreferencesVisible,
            buttonText:
                AppLocalizations.of(context).tr('irc.connection.edit.action'
                    '.save'));

  @override
  successCallback(BuildContext context, ChatNetworkPreferences preferences)
  async {
    final NetworkBloc networkBloc = NetworkBloc.of(context);

    var result = await doAsyncOperationWithDialog(
        context: context,
        asyncCode: () async {
          return await networkBloc.editNetworkSettings(preferences);
        },
        cancellationValue: null,
        isDismissible: true);

    if (result.isNotCanceled) {
      Navigator.pop(context);
    }

    return result;
  }
}
