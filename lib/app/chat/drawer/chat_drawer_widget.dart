import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_edit_connection_page.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/lounge_preferences_bloc.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/network/list/network_list_widget.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_new_preferences_page.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/skin_day_night_widget.dart';
import 'package:flutter_appirc/socketio/socketio_manager_provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatDrawerWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  ChatDrawerWidget({this.onActionCallback});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: NetworkListWidget(onActionCallback)),
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

          Navigator.push(
              context,
              platformPageRoute(
                  context: context,
                  builder: (context) {
                    var networkEnabled = !backendService.chatConfig.lockNetwork;
                    var newChatNetworkPage = NewNetworkPreferencesPage.name(
                      context: context,
                      startValues: backendService.chatConfig
                          .createDefaultNetworkPreferences(),
                      serverPreferencesEnabled: networkEnabled,
                      serverPreferencesVisible:
                          backendService.chatConfig.displayNetwork,
                      outerCallback: () {
                        Navigator.pop(context);
                      },
                    );
                    return newChatNetworkPage;
                  }));
        },
        material: (context, platform) => MaterialIconButtonData(
          icon: Icon(
            Icons.add,
          ),
        ),
        cupertino: (context, platform) => CupertinoIconButtonData(
          icon: Icon(
            CupertinoIcons.add,
          ),
        ),
      );

  Widget _buildLoungeSettingsButton(BuildContext context) => PlatformIconButton(
        onPressed: () async {
          var settings = Provider.of<LoungePreferencesBloc>(context).getValue(
            defaultValue: createDefaultLoungePreferences(
              context,
            ),
          );
          await Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (context) {
                var connectionBloc = LoungeConnectionBloc(
                    Provider.of<SocketIOManagerProvider>(context).manager,
                    settings.hostPreferences,
                    settings.authPreferences);
                return Provider(
                  providable: connectionBloc,
                  child: Provider(
                    providable: LoungeConnectionFormBloc(connectionBloc),
                    child: EditLoungeConnectionPage(),
                  ),
                );
              },
            ),
          );
        },
        icon: Icon(Icons.settings),
        cupertino: (context, platform) => CupertinoIconButtonData(
          icon: Icon(
            CupertinoIcons.settings,
          ),
        ),
      );

  Widget _buildSignOutButton(BuildContext context) => PlatformIconButton(
      onPressed: () async {
        var loungeBackendService = Provider.of<LoungeBackendService>(context);

        loungeBackendService.signOut();
      },
      icon: Icon(Icons.exit_to_app));
}
