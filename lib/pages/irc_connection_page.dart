import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_connection_bloc.dart';
import 'package:flutter_appirc/pages/chat_page.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/irc_connection_widget.dart';
import 'package:flutter_appirc/widgets/loading_button_widget.dart';

class IRCConnectionPage extends StatefulWidget {
  final bool isOpenedFromAppStart;

  IRCConnectionPage({this.isOpenedFromAppStart = false});

  @override
  State<StatefulWidget> createState() {
    return IRCConnectionState(isOpenedFromAppStart);
  }
}

class IRCConnectionState extends State<IRCConnectionPage> {
  final bool isOpenedFromAppStart;

  IRCConnectionState(this.isOpenedFromAppStart);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final LoungeService loungeService = Provider.of<LoungeService>(context);
    var ircConnectionBloc = IRCConnectionBloc(loungeService);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('irc_connection.title')),
      ),
      body: Column(
        children: <Widget>[
          Provider<IRCConnectionBloc>(
            bloc: ircConnectionBloc,
            child: Expanded(
              child: ListView(shrinkWrap: true, children: [
                NetworkPreferencesConnectionFormWidget(),
                UserPreferencesConnectionFormWidget()
              ]),
            ),
          ),
          Provider<AsyncOperationBloc>(
            bloc: ircConnectionBloc,
            child: LoadingButtonWidget(
              child:
                  Text(AppLocalizations.of(context).tr('irc_connection.connect')),
              onPressed: () {
                _sendNetworkRequest(ircConnectionBloc, context);
              },
            ),
          )
        ],
      ),
    );
  }

  void _sendNetworkRequest(
      IRCConnectionBloc ircConnectionBloc, BuildContext context) async {
    await ircConnectionBloc.sendNewNetworkRequest();
    if (isOpenedFromAppStart) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ChatPage()));
    } else {
      Navigator.pop(context);
    }
  }
}
