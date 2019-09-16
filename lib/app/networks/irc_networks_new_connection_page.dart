import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_bloc.dart';
import 'package:flutter_appirc/app/chat/irc_chat_page.dart';
import 'package:flutter_appirc/app/chat/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_model.dart';
import 'package:flutter_appirc/app/networks/irc_network_preferences_widget.dart';
import 'package:flutter_appirc/app/networks/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/async/async_operation_bloc.dart';
import 'package:flutter_appirc/async/button_loading_widget.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NewChatNetworkPage extends StatefulWidget {
  final IRCNetworkPreferences startValues;
  final VoidCallback successCallback;

  NewChatNetworkPage(this.startValues, {this.successCallback});

  @override
  State<StatefulWidget> createState() {
    return NewChatNetworkPageState(startValues,
        successCallback: successCallback);
  }
}

class NewChatNetworkPageState extends State<NewChatNetworkPage> {
  final IRCNetworkPreferences startValues;
  final VoidCallback successCallback;

  NewChatNetworkPageState(this.startValues, {this.successCallback});

  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('irc_connection.title')),
      ),
      body: Provider<ChatNewNetworkBloc>(
        bloc: chatBloc.createNewChatNetworkBloc(startValues),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                IRCNetworkPreferencesWidget(
                    ircNetworksNewConnectionBloc.newConnectionPreferences),
                Provider<AsyncOperationBloc>(
                  bloc: ircNetworksNewConnectionBloc,
                  child: ButtonLoadingWidget(
                    child: Text(
                      AppLocalizations.of(context).tr('irc_connection.connect'),
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
//                      var newChatNetworkBloc = Provider.of<NewChatNetworkBloc>(context);
//                      _sendNetworkRequest(
//                          ircNetworksNewConnectionBloc, context);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendNetworkRequest(
      ChatNewNetworkBloc ircNetworksNewConnectionBloc,
      BuildContext context) async {
    try {
      await ircNetworksNewConnectionBloc.sendNewNetworkRequest();
      if (isOpenedFromAppStart) {
        Navigator.pushReplacement(
            context, platformPageRoute(builder: (context) => ChatPage()));
      } else {
        Navigator.pop(context);
      }
    } on ServerNameNotUniqueException catch (e) {
      var appLocalizations = AppLocalizations.of(context);

      showPlatformDialog(
          androidBarrierDismissible: true,
          context: context,
          builder: (_) => PlatformAlertDialog(
                title: Text(appLocalizations
                    .tr("irc_connection.not_unique_name_dialog.title")),
                content: Text(appLocalizations
                    .tr("irc_connection.not_unique_name_dialog.content")),
              ));
    }
  }
}
