import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/log_service.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/loading_button_widget.dart';
import 'package:flutter_appirc/widgets/lounge_connection_widget.dart';

const _logTag = "LoungeConnectionPage";

class LoungeConnectionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoungeConnectionState();
  }
}

class LoungeConnectionState extends State<LoungeConnectionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final LoungeService lounge = Provider.of<LoungeService>(context);
    var loungeConnectionBloc = NewLoungeConnectionBloc(
        loungeService: lounge,
        preferencesBloc: Provider.of<LoungePreferencesBloc>(context),
        newConnectionPreferences: createDefaultLoungePreferences());

    return Provider<NewLoungeConnectionBloc>(
      bloc: loungeConnectionBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title:
              Text(AppLocalizations.of(context).tr('lounge_connection.title')),
        ),
        body: Column(
          children: <Widget>[
            Provider<NewLoungeConnectionBloc>(
              bloc: loungeConnectionBloc,
              child: LoungePreferencesConnectionFormWidget(),
            ),
            Provider<AsyncOperationBloc>(
              bloc: loungeConnectionBloc,
              child: LoadingButtonWidget(
                child: Text(AppLocalizations.of(context)
                    .tr('lounge_connection.connect')),
                onPressed: () => connectToLounge(context, loungeConnectionBloc)
                      .then((connected) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => IRCNetworksNewConnectionPage(
                                isOpenedFromAppStart: true)));
                  }),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<bool> connectToLounge(
    BuildContext context, NewLoungeConnectionBloc loungeConnectionBloc) async {
  logi(_logTag, "Connecting to $loungeConnectionBloc.");

  bool connected = true;
  Exception exception;
  try {
    await loungeConnectionBloc.connect();
  } on Exception catch (e) {
    connected = false;
    exception = e;
  }
  logi(_logTag, "Connected = $connected");

  if (!connected) {
    if (exception is ConnectionException) {
      ConnectionException connectionException = exception;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text(connectionException.alertDialogTitle(context)),
            content: Text(connectionException.alertDialogContent(context))),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)
                .tr('lounge_connection.dialog.connection_error.title')),
            content: Text(AppLocalizations.of(context).tr(
                'lounge_connection.dialog.connection_error.content',
                args: [exception.toString()]))),
      );
    }
  } else {}
  return connected;
}
