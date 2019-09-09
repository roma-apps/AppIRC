import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/models/irc_network_model.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_join_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_users_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelUsersPage extends StatefulWidget {
  final IRCNetworkChannel channel;

  IRCNetworkChannelUsersPage(this.channel);

  @override
  State<StatefulWidget> createState() {
    return IRCNetworkChannelUsersPageState(channel);
  }
}

class IRCNetworkChannelUsersPageState extends State<IRCNetworkChannelUsersPage> {
  final IRCNetworkChannel channel;

  IRCNetworkChannelUsersPageState(this.channel);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('chat.users.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IRCNetworkChannelUsersWidget(channel),
        ),
      ),
    );
  }
}
