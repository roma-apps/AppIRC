import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/pages/irc_networks_new_connection_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';
import 'package:flutter_appirc/widgets/lounge_preferences_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoungeNewConnectionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoungeNewConnectionPageState();
  }
}

class LoungeNewConnectionPageState extends State<LoungeNewConnectionPage> {
  @override
  Widget build(BuildContext context) {
    final LoungeService lounge = Provider.of<LoungeService>(context);
    var loungePreferences = createDefaultLoungePreferences();
    var loungeConnectionBloc = LoungeNewConnectionBloc(
        loungeService: lounge,
        preferencesBloc: Provider.of<LoungePreferencesBloc>(context),
        newLoungePreferences: loungePreferences);

    return SafeArea(
      child: Provider<LoungeNewConnectionBloc>(
        bloc: loungeConnectionBloc,
        child: PlatformScaffold(
          iosContentBottomPadding: true,
          iosContentPadding: true,
          appBar: PlatformAppBar(
            title: Text(
                AppLocalizations.of(context).tr('lounge.connection.new.title')),
          ),
          body: Column(
            children: <Widget>[
              Provider<LoungeNewConnectionBloc>(
                bloc: loungeConnectionBloc,
                child: Provider<LoungeConnectionBloc>(
                    bloc: loungeConnectionBloc,
                    child: LoungePreferencesWidget(loungePreferences)),
              ),
              Provider<AsyncOperationBloc>(
                bloc: loungeConnectionBloc,
                child: ButtonLoadingWidget(
                  child: Text(AppLocalizations.of(context)
                      .tr('lounge.connection.new.connect')),
                  onPressed: () =>
                      connectToLounge(context, loungeConnectionBloc)
                          .then((connected) {
                    if (connected) {
                      Navigator.pushReplacement(
                          context,
                          platformPageRoute(
                              builder: (context) =>
                                  IRCNetworksNewConnectionPage(
                                      isOpenedFromAppStart: true)));
                    }
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
