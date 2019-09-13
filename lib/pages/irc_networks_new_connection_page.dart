import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/pages/irc_chat_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_preferences_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworksNewConnectionPage extends StatefulWidget {
  final bool isOpenedFromAppStart;

  IRCNetworksNewConnectionPage({this.isOpenedFromAppStart = false});

  @override
  State<StatefulWidget> createState() {
    return IRCNetworksNewConnectionPageState(isOpenedFromAppStart);
  }
}

class IRCNetworksNewConnectionPageState
    extends State<IRCNetworksNewConnectionPage> {
  final bool isOpenedFromAppStart;

  IRCNetworksNewConnectionPageState(this.isOpenedFromAppStart);

  @override
  Widget build(BuildContext context) {
    final LoungeService loungeService = Provider.of<LoungeService>(context);
    var connectionPreferences = createDefaultIRCNetworkPreferences();
    var ircNetworksNewConnectionBloc = IRCNetworksNewConnectionBloc(
        loungeService: loungeService,
        preferencesBloc: Provider.of<IRCNetworksPreferencesBloc>(context),
        newConnectionPreferences: connectionPreferences);

    return PlatformScaffold(
      iosContentBottomPadding: true,
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('irc_connection.title')),
      ),
      body: Provider<IRCNetworksNewConnectionBloc>(
        bloc: ircNetworksNewConnectionBloc,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                children: <Widget>[
                  IRCNetworkPreferencesWidget(ircNetworksNewConnectionBloc.newConnectionPreferences),
                ],
              ),
              Provider<AsyncOperationBloc>(
                bloc: ircNetworksNewConnectionBloc,
                child: ButtonLoadingWidget(
                  child: Text(AppLocalizations.of(context)
                      .tr('irc_connection.connect')),
                  onPressed: () {
                    _sendNetworkRequest(ircNetworksNewConnectionBloc, context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _sendNetworkRequest(
      IRCNetworksNewConnectionBloc ircNetworksNewConnectionBloc,
      BuildContext context) async {
    try {
      await ircNetworksNewConnectionBloc.sendNewNetworkRequest();
      if (isOpenedFromAppStart) {
        Navigator.pushReplacement(
            context, platformPageRoute(builder: (context) => IRCChatPage()));
      } else {
        Navigator.pop(context);
      }
    } on ServerNameNotUniqueException catch (e) {
      var appLocalizations = AppLocalizations.of(context);

      showPlatformDialog(
          androidBarrierDismissible: true,
          context: context,
          builder: (_) => PlatformAlertDialog(
                title: Text(appLocalizations.tr("irc_connection.not_unique_name_dialog.title")),
                content: Text(appLocalizations.tr("irc_connection.not_unique_name_dialog.content")),
              ));
    }


  }
}
