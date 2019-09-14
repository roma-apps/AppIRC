import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_preferences_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkEditPage extends StatefulWidget {
  final IRCNetwork network;

  IRCNetworkEditPage(this.network);

  @override
  State<StatefulWidget> createState() {
    return IRCNetworksNewConnectionState(network);
  }
}

class IRCNetworksNewConnectionState extends State<IRCNetworkEditPage> {
  final IRCNetwork network;

  IRCNetworksNewConnectionState(this.network);

  @override
  Widget build(BuildContext context) {
    final LoungeService loungeService = Provider.of<LoungeService>(context);
    var defaultIRCNetworkPreferences = createDefaultIRCNetworkPreferences();
    var ircNetworksNewConnectionBloc = IRCNetworksNewConnectionBloc(
        loungeService: loungeService,
        preferencesBloc: Provider.of<IRCNetworksPreferencesBloc>(context),
        newConnectionPreferences: defaultIRCNetworkPreferences);

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,

      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('irc_connection.title')),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Provider<IRCNetworksNewConnectionBloc>(
                bloc: ircNetworksNewConnectionBloc,
                child:
                    IRCNetworkPreferencesWidget(defaultIRCNetworkPreferences)),
            Provider<AsyncOperationBloc>(
              bloc: ircNetworksNewConnectionBloc,
              child: ButtonLoadingWidget(
                child: Text(
                  AppLocalizations.of(context).tr('irc_connection.save'),
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _saveNetworkSettings(ircNetworksNewConnectionBloc, context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _saveNetworkSettings(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc,
      BuildContext context) async {
//    await ircNetworksNewConnectionBloc.sendNewNetworkRequest();

    Navigator.pop(context);
  }
}
