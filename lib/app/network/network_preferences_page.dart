import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_widget.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NewChatNetworkPage extends ChatNetworkPage {
  final VoidCallback successCallback;

  NewChatNetworkPage(BuildContext context, ChatNetworkPreferences startValues,
      this.successCallback)
      : super(AppLocalizations.of(context).tr('irc_connection.title'),
            startValues, (context, preferences) async {
          final ChatNetworksListBloc chatBloc =
              Provider.of<ChatNetworksListBloc>(context);

          await doAsyncOperationWithDialog(context, () async {
            var result = await chatBloc.joinNetwork(preferences);

            successCallback();

            return result;
          });
        }, true, false,
            AppLocalizations.of(context).tr('irc_connection.connect'));
}

class EditChatNetworkPage extends ChatNetworkPage {
  EditChatNetworkPage(BuildContext context, ChatNetworkPreferences startValues)
      : super(AppLocalizations.of(context).tr('irc_connection.title_edit'),
            startValues, (context, preferences) async {
          final NetworkBloc networkBloc = Provider.of<NetworkBloc>(context);

          var result = await doAsyncOperationWithDialog(context, () async {
            return await networkBloc.editNetworkSettings(preferences);
          });

          Navigator.pop(context);

          return result;
        }, false, true, AppLocalizations.of(context).tr('irc_connection.save'));
}

class ChatNetworkPage extends StatefulWidget {
  final ChatNetworkPreferences startValues;
  final ChatNetworkPreferencesActionCallback callback;

  final bool isNeedShowChannels;
  final bool isNeedShowCommands;
  final String buttonText;
  final String titleText;

  ChatNetworkPage(this.titleText, this.startValues, this.callback,
      this.isNeedShowChannels, this.isNeedShowCommands, this.buttonText);

  @override
  State<StatefulWidget> createState() {
    return ChatNetworkPageState(titleText, startValues, callback,
        isNeedShowChannels, isNeedShowCommands, buttonText);
  }
}

class ChatNetworkPageState extends State<ChatNetworkPage> {
  final ChatNetworkPreferences startValues;
  final ChatNetworkPreferencesActionCallback callback;
  final String buttonText;

  ChatNetworkPreferencesFormBloc networkPreferencesFormBloc;

  final String titleText;

  ChatNetworkPageState(this.titleText, this.startValues, this.callback,
      bool isNeedShowChannels, bool isNeedShowCommands, this.buttonText) {
    networkPreferencesFormBloc = ChatNetworkPreferencesFormBloc(
        startValues, isNeedShowChannels, isNeedShowCommands);
  }

  @override
  void dispose() {
    super.dispose();
    networkPreferencesFormBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatNetworksListBloc chatBloc =
        Provider.of<ChatNetworksListBloc>(context);
    networkPreferencesFormBloc.networkValidator =
        CustomValidator((networkName) async {
      var alreadyExist = await chatBloc.isNetworkWithNameExist(networkName);
      ValidationError error;
      if (alreadyExist) {
        error = NotUniqueValidationError();
      }
      return error;
    });

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(titleText),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider(
            providable: networkPreferencesFormBloc,
            child: ChatNetworkPreferencesFormWidget(
                startValues, callback, buttonText),
          ),
        ),
      ),
    );
  }
}
