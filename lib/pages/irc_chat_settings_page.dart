import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/widgets/irc_chat_settings_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCChatSettingsPage extends StatefulWidget {
  IRCChatSettingsPage();

  @override
  State<StatefulWidget> createState() {
    return IRCNetworksListState();
  }
}

class IRCNetworksListState extends State<IRCChatSettingsPage> {
  IRCNetworksListState();

  @override
  Widget build(BuildContext context) => PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('settings.title')),
      ),
      body: SafeArea(child: IRCChatSettingsWidget()));
}
