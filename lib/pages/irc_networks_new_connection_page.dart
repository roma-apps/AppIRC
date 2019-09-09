import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/pages/irc_chat_page.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_server_preferences_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_user_preferences_widget.dart';

class IRCNetworksNewConnectionPage extends StatefulWidget {
  final bool isOpenedFromAppStart;

  IRCNetworksNewConnectionPage({this.isOpenedFromAppStart = false});

  @override
  State<StatefulWidget> createState() {
    return IRCNetworksNewConnectionState(isOpenedFromAppStart);
  }
}

class IRCNetworksNewConnectionState
    extends State<IRCNetworksNewConnectionPage> {
  final bool isOpenedFromAppStart;

  IRCNetworksNewConnectionState(this.isOpenedFromAppStart);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final LoungeService loungeService = Provider.of<LoungeService>(context);
    var ircNetworksNewConnectionBloc = IRCNetworksNewConnectionBloc(
        loungeService: loungeService,
        preferencesBloc: Provider.of<IRCNetworksPreferencesBloc>(context),
        newConnectionPreferences: createDefaultIRCNetworkPreferences());

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('irc_connection.title')),
      ),
      body: Column(
        children: <Widget>[
          Provider<IRCNetworksNewConnectionBloc>(
            bloc: ircNetworksNewConnectionBloc,
            child: Expanded(
              child: ListView(shrinkWrap: true, children: [
                IRCNetworkServerPreferencesWidget(),
                IRCNetworkUserPreferencesWidget()
              ]),
            ),
          ),
          Provider<AsyncOperationBloc>(
            bloc: ircNetworksNewConnectionBloc,
            child: ButtonLoadingWidget(
              child: Text(
                  AppLocalizations.of(context).tr('irc_connection.connect')),
              onPressed: () {
                _sendNetworkRequest(ircNetworksNewConnectionBloc, context);
              },
            ),
          )
        ],
      ),
    );
  }

  void _sendNetworkRequest(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc,
      BuildContext context) async {
    await ircNetworksNewConnectionBloc.sendNewNetworkRequest();
    if (isOpenedFromAppStart) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => IRCChatPage()));
    } else {
      Navigator.pop(context);
    }
  }
}
