import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_preferences_page.dart';
import 'package:flutter_appirc/dialog/async/async_dialog.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class NewNetworkPreferencesPage extends NetworkPreferencesPage {
  final VoidCallback outerCallback;

  NewNetworkPreferencesPage.name({
    @required BuildContext context,
    @required NetworkPreferences startValues,
    @required bool serverPreferencesEnabled,
    @required bool serverPreferencesVisible,
    this.outerCallback,
  }) : super.name(
          titleText: S.of(context).irc_connection_new_title,
          startValues: startValues,
          isNeedShowChannels: true,
          isNeedShowCommands: false,
          serverPreferencesEnabled: serverPreferencesEnabled,
          serverPreferencesVisible: serverPreferencesVisible,
          buttonText: S.of(context).irc_connection_new_action_connect,
        );

  @override
  Future successCallback(
    BuildContext context,
    NetworkPreferences preferences,
  ) async {
    final chatBloc = Provider.of<NetworkListBloc>(context);

    var dialogResult = await doAsyncOperationWithDialog(
      context: context,
      asyncCode: () async {
        var result = await chatBloc.joinNetwork(preferences);

        return result;
      },
      cancelable: true,
    );

    if (dialogResult.success) {
      outerCallback();
    }
  }
}
