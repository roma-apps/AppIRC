import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_preferences_page.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NewNetworkPreferencesPage extends NetworkPreferencesPage {
  final VoidCallback outerCallback;

  NewNetworkPreferencesPage.name(
      {@required BuildContext context,
      @required NetworkPreferences startValues,
      @required bool serverPreferencesEnabled,
      @required bool serverPreferencesVisible,
      this.outerCallback})
      : super.name(
            titleText:
                tr('irc.connection.new.title'),
            startValues: startValues,
            isNeedShowChannels: true,
            isNeedShowCommands: false,
            serverPreferencesEnabled: serverPreferencesEnabled,
            serverPreferencesVisible: serverPreferencesVisible,
            buttonText: tr('irc.connection.new.action.connect'));

  @override
  successCallback(
      BuildContext context, NetworkPreferences preferences) async {
    final NetworkListBloc chatBloc =
        Provider.of<NetworkListBloc>(context);

    var dialogResult = await doAsyncOperationWithDialog(
        context: context,
        asyncCode: () async {
          var result = await chatBloc.joinNetwork(preferences);

          return result;
        },
        cancellationValue: null,
        isDismissible: true);

    if (dialogResult.isNotCanceled) {
      outerCallback();
    }
  }
}
