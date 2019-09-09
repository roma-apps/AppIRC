import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_new_connection_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_preferences_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/pages/irc_chat_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/button_loading_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_server_preferences_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_user_preferences_widget.dart';
import 'package:flutter_appirc/widgets/irc_networks_list_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworksListPage extends StatefulWidget {

  IRCNetworksListPage();

  @override
  State<StatefulWidget> createState() {
    return IRCNetworksListState();
  }
}

class IRCNetworksListState extends State<IRCNetworksListPage> {

  IRCNetworksListState();

  @override
  Widget build(BuildContext context) =>
      PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(AppLocalizations.of(context).tr('networks_list.title')),
          ),
          body: SafeArea(child: IRCNetworksListWidget())
      );

}
