import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_preferences_page.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/network/network_preferences_page.dart';
import 'package:flutter_appirc/app/network/networks_list_widget.dart';
import 'package:flutter_appirc/skin/skin_day_night_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatDrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: NetworksListWidget()),
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppSkinDayNightIconButton(),
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
                  builder: (context) => NewChatNetworkPage(
                          createDefaultNetworkPreferences(context), () {
                        Navigator.pop(context);
                      })));
        },
        androidIcon: Icon(Icons.add),
        iosIcon: Icon(CupertinoIcons.add),
      );

  Widget _buildLoungeSettingsButton(BuildContext context) => PlatformIconButton(
        onPressed: () async {
          var settings = Provider.of<LoungePreferencesBloc>(context)
              .getValue(defaultValue: createDefaultLoungePreferences(context));
          Navigator.push(
              context,
              platformPageRoute(
                  builder: (context) => EditLoungePreferencesPage(settings)));
        },
        androidIcon: Icon(Icons.settings),
        iosIcon: Icon(CupertinoIcons.settings),
      );
}
