import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_edit_connection_page.dart';
import 'package:flutter_appirc/app/networks/irc_networks_list_widget.dart';
import 'package:flutter_appirc/app/networks/irc_networks_new_connection_page.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCChatSettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: IRCNetworksListWidget()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildNewNetworkButton(context),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildLoungeSettingsButton(context),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildNewNetworkButton(BuildContext context) => PlatformIconButton(
        onPressed: () {
          Navigator.push(
              context,
              platformPageRoute(
                  builder: (context) => IRCNetworksNewConnectionPage()));
        },
        androidIcon: Icon(Icons.add),
        iosIcon: Icon(CupertinoIcons.add),
      );

  Widget _buildLoungeSettingsButton(BuildContext context) => PlatformIconButton(
        onPressed: () {
          Navigator.push(
              context,
              platformPageRoute(
                  builder: (context) => LoungeEditConnectionPage()));
        },
        androidIcon: Icon(Icons.settings),
        iosIcon: Icon(CupertinoIcons.settings),
      );
}
