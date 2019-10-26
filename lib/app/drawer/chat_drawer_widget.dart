import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/page/lounge_edit_preferences_page.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/network/list/networks_list_widget.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_page.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_day_night_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatDrawerWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  ChatDrawerWidget({this.onActionCallback});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Expanded(child: NetworksListWidget(onActionCallback)),
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildSignOutButton(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewNetworkButton(BuildContext context) => PlatformIconButton(
        onPressed: () {
          ChatBackendService backendService = Provider.of(context);

          Navigator.push(context, platformPageRoute(builder: (context) {
            var newChatNetworkPage = NewChatNetworkPage(
              context,
              createDefaultNetworkPreferences(context),
              !backendService.chatConfig.lockNetwork,
              backendService.chatConfig.displayNetwork,
              () {
                Navigator.pop(context);
              },
            );
            return newChatNetworkPage;
          }));
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
        icon: Icon(Icons.settings),
        iosIcon: Icon(CupertinoIcons.settings),
      );
  Widget _buildSignOutButton(BuildContext context) => PlatformIconButton(
        onPressed: () async {
          var loungeBackendService = Provider.of<LoungeBackendService>(context);

          loungeBackendService.signOut();
        },
        icon: Icon(Icons.exit_to_app)
      );
}
