import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/networks/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_preferences_page.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NewChatNetworkPage extends ChatNetworkPreferencesPage {
  final VoidCallback outerCallback;

  NewChatNetworkPage.name(
      {@required BuildContext context,
      @required ChatNetworkPreferences startValues,
      @required bool serverPreferencesEnabled,
      @required bool serverPreferencesVisible,
      this.outerCallback})
      : super.name(
            titleText:
                AppLocalizations.of(context).tr('irc.connection.new.title'),
            startValues: startValues,
            isNeedShowChannels: true,
            isNeedShowCommands: false,
            serverPreferencesEnabled: serverPreferencesEnabled,
            serverPreferencesVisible: serverPreferencesVisible,
            buttonText: AppLocalizations.of(context)
                .tr('irc.connection.new.action.connect'));

  @override
  successCallback(
      BuildContext context, ChatNetworkPreferences preferences) async {
    final ChatNetworksListBloc chatBloc =
        Provider.of<ChatNetworksListBloc>(context);

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
