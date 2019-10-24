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

  NewChatNetworkPage(
      BuildContext context,
      ChatNetworkPreferences startValues,
      bool serverPreferencesEnabled,
      bool serverPreferencesVisible,
      this.successCallback)
      : super(AppLocalizations.of(context).tr('irc.connection.new.title'),
            startValues, (context, preferences) async {
          final ChatNetworksListBloc chatBloc =
              Provider.of<ChatNetworksListBloc>(context);

          var dialogResult = await doAsyncOperationWithDialog(context,
              asyncCode:() async {
            var result = await chatBloc.joinNetwork(preferences);



            return result;
          }, cancellationValue: null, isDismissible: true);

          if(dialogResult.isNotCanceled) {
            successCallback();
          }
        }, true, false, serverPreferencesEnabled, serverPreferencesVisible,
            AppLocalizations.of(context).tr('irc.connection.new.action'
                '.connect'));
}

class EditChatNetworkPage extends ChatNetworkPage {
  EditChatNetworkPage(BuildContext context, ChatNetworkPreferences startValues,
      bool serverPreferencesEnabled, bool serverPreferencesVisible)
      : super(AppLocalizations.of(context).tr('irc.connection.edit.title'),
            startValues, (context, preferences) async {
          final NetworkBloc networkBloc = NetworkBloc.of(context);

          var result = await doAsyncOperationWithDialog(context, asyncCode: ()
          async {
            return await networkBloc.editNetworkSettings(preferences);
          }, cancellationValue: null, isDismissible: true);

          if(result.isNotCanceled) {
            Navigator.pop(context);
          }

          return result;
        }, false, true, serverPreferencesEnabled, serverPreferencesVisible,
            AppLocalizations.of(context).tr('irc.connection.edit.action.save'));
}

class ChatNetworkPage extends StatefulWidget {
  final ChatNetworkPreferences startValues;
  final ChatNetworkPreferencesActionCallback callback;

  final bool isNeedShowChannels;
  final bool isNeedShowCommands;
  final bool serverPreferencesEnabled;
  final bool serverPreferencesVisible;
  final String buttonText;
  final String titleText;

  ChatNetworkPage(
      this.titleText,
      this.startValues,
      this.callback,
      this.isNeedShowChannels,
      this.isNeedShowCommands,
      this.serverPreferencesEnabled,
      this.serverPreferencesVisible,
      this.buttonText);

  @override
  State<StatefulWidget> createState() {
    return ChatNetworkPageState(
        titleText,
        startValues,
        callback,
        isNeedShowChannels,
        isNeedShowCommands,
        serverPreferencesEnabled,
        serverPreferencesVisible,
        buttonText);
  }
}

class ChatNetworkPageState extends State<ChatNetworkPage> {
  final ChatNetworkPreferences startValues;
  final ChatNetworkPreferencesActionCallback callback;
  final String buttonText;

  ChatNetworkPreferencesFormBloc networkPreferencesFormBloc;

  final String titleText;

  ChatNetworkPageState(
      this.titleText,
      this.startValues,
      this.callback,
      bool isNeedShowChannels,
      bool isNeedShowCommands,
      bool serverPreferencesEnabled,
      bool serverPreferencesVisible,
      this.buttonText) {
    networkPreferencesFormBloc = ChatNetworkPreferencesFormBloc(
        startValues,
        isNeedShowChannels,
        isNeedShowCommands,
        serverPreferencesEnabled,
        serverPreferencesVisible);
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
      iosContentPadding: false,
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
