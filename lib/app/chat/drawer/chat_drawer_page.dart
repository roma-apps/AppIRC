import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/drawer/chat_drawer_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatDrawerPage extends StatelessWidget {
  const ChatDrawerPage();

  @override
  Widget build(BuildContext context) => buildPlatformScaffold(
        context,
        appBar: PlatformAppBar(
          title: Text(
            S.of(context).chat_settings_title,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatDrawerWidget(
              onActionCallback: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );
}
