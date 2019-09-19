import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_widget.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NewChatNetworkPage extends ChatNetworkPage {
  final VoidCallback successCallback;

  NewChatNetworkPage(IRCNetworkPreferences startValues, this.successCallback)
      : super(startValues, (context, preferences) async {
          final ChatNetworksListBloc chatBloc =
              Provider.of<ChatNetworksListBloc>(context);

          await doAsyncOperationWithDialog(context, () async {
            var result = await chatBloc.joinNetwork(preferences);

            successCallback();

            return result;
          });
        });
}

class EditChatNetworkPage extends ChatNetworkPage {
  EditChatNetworkPage(IRCNetworkPreferences startValues)
      : super(startValues, (context, preferences) async {
          final ChatNetworksListBloc chatBloc =
              Provider.of<ChatNetworksListBloc>(context);

          var result = await doAsyncOperationWithDialog(context, () async {
            return await chatBloc.joinNetwork(preferences);

            // name should be unique
//
//      showPlatformDialog(
//          androidBarrierDismissible: true,
//          context: context,
//          builder: (_) => PlatformAlertDialog(
//            title: Text(appLocalizations
//                .tr("irc_connection.not_unique_name_dialog.title")),
//            content: Text(appLocalizations
//                .tr("irc_connection.not_unique_name_dialog.content")),
//          ));
          });

          Navigator.pop(context);

          return result;
        });
}

class ChatNetworkPage extends StatefulWidget {
  final IRCNetworkPreferences startValues;
  final PreferencesActionCallback callback;

  ChatNetworkPage(this.startValues, this.callback);

  @override
  State<StatefulWidget> createState() {
    return ChatNetworkPageState(startValues, callback);
  }
}

class ChatNetworkPageState extends State<ChatNetworkPage> {
  final IRCNetworkPreferences startValues;
  final PreferencesActionCallback callback;

  IRCNetworkPreferencesFormBloc networkPreferencesFormBloc;

  ChatNetworkPageState(this.startValues, this.callback) {
    networkPreferencesFormBloc = IRCNetworkPreferencesFormBloc(startValues);
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
        title: Text(AppLocalizations.of(context).tr('irc_connection.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider(
            providable: networkPreferencesFormBloc,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                IRCNetworkPreferencesFormWidget(startValues, callback),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
