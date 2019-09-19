import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/chat_drawer_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatDrawerPage extends StatefulWidget {
  ChatDrawerPage();

  @override
  State<StatefulWidget> createState() {
    return ChatDrawerPageState();
  }
}

class ChatDrawerPageState extends State<ChatDrawerPage> {
  ChatDrawerPageState();

  @override
  Widget build(BuildContext context) => PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('settings.title')),
      ),
      body: SafeArea(child: ChatDrawerWidget()));
}
