import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/page/lounge_edit_connection_page.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/instance/current/current_auth_instance_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_widget.dart';
import 'package:flutter_appirc/app/network/preferences/page/network_new_preferences_page.dart';
import 'package:flutter_appirc/disposable/disposable_provider.dart';
import 'package:flutter_appirc/socketio/socket_io_service.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

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
            Padding(padding: const EdgeInsets.all(8.0), child: Text("missqewd")
                // child:
                // AppSkinDayNightIconButton(),
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
          var backendService =
              Provider.of<ChatBackendService>(context, listen: false);

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
              },
            ),
          );
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
          var currentAuthInstanceBloc = ICurrentAuthInstanceBloc.of(context);

          var settings = currentAuthInstanceBloc.currentInstance ??
              createDefaultLoungePreferences();
          await Navigator.push(
            context,
            platformPageRoute(
              context: context,
              builder: (context) {
                return DisposableProvider<LoungeConnectionBloc>(
                  create: (context) => LoungeConnectionBloc(
                    Provider.of<SocketIOService>(context),
                    settings.hostPreferences,
                    settings.authPreferences,
                  ),
                  child: DisposableProxyProvider<LoungeConnectionBloc,
                      LoungeConnectionFormBloc>(
                    update: (context, connectionBloc, previous) =>
                        LoungeConnectionFormBloc(connectionBloc),
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
