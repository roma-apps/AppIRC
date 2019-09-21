import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, AppBar, Drawer;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_topic_widget.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_drawer_page.dart';
import 'package:flutter_appirc/app/chat/chat_drawer_widget.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/default_values.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_widget.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/app/user/users_list_page.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var preferencesService = Provider.of<PreferencesService>(context);
    var networksListBloc = Provider.of<ChatNetworksListBloc>(context);

    return Provider<IRCChatActiveChannelBloc>(
        providable:
            IRCChatActiveChannelBloc(networksListBloc, preferencesService),
        child: SafeArea(
          child: PlatformScaffold(
              android: (context) => MaterialScaffoldData(
                  appBar: AppBar(
                    title: _buildAppBarChild(context),
                    actions: <Widget>[
                      buildMembersButton(context),
                    ],
                  ),
                  drawer: Drawer(child: ChatDrawerWidget()),
                  body: _buildBody(context)),
              ios: (context) => CupertinoPageScaffoldData(
                  resizeToAvoidBottomInset: true,
                  body: _buildBody(context),
                  navigationBar: CupertinoNavigationBar(
                    leading: PlatformIconButton(
                      androidIcon: Icon(Icons.menu),
                      iosIcon: Icon(Icons.menu),
                      onPressed: () {
                        Navigator.push(
                            context,
                            platformPageRoute(
                                builder: (context) => ChatDrawerPage()));
                      },
                    ),
                    trailing: buildMembersButton(context),
                    middle: _buildAppBarChild(context),
                  ))),
        ));
  }

  Widget buildMembersButton(BuildContext context) {
    var activeChannelBloc = Provider.of<IRCChatActiveChannelBloc>(context);
    return StreamBuilder<NetworkChannel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context,
          AsyncSnapshot<NetworkChannel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return Container();
        } else {
          return PlatformIconButton(
            androidIcon: Icon(Icons.group),
            iosIcon: Icon(CupertinoIcons.group_solid),
            onPressed: () {
              var networkListBloc = Provider.of<ChatNetworksListBloc>(context);
              var network = networkListBloc.findNetworkWithChannel(channel);
              Navigator.push(
                  context,
                  platformPageRoute(
                      builder: (context) =>
                          IRCNetworkChannelUsersPage(network, channel)));
            },
          );
        }
      },
    );
  }

  Widget _buildAppBarChild(BuildContext context) {
    var backendService = Provider.of<LoungeBackendService>(context);

    var activeChannelBloc = Provider.of<IRCChatActiveChannelBloc>(context);
    var connectionBloc = Provider.of<ChatConnectionBloc>(context);
    var networkListBloc = Provider.of<ChatNetworksListBloc>(context);
    var channelsStateBloc = Provider.of<ChatNetworkChannelsStateBloc>(context);

    return StreamBuilder<NetworkChannel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context,
          AsyncSnapshot<NetworkChannel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return StreamBuilder<ChatConnectionState>(
              stream: connectionBloc.connectionStateStream,
              initialData: connectionBloc.connectionState,
              builder: (BuildContext context,
                  AsyncSnapshot<ChatConnectionState> snapshot) {
                var connectionState = snapshot.data;

                var title = Text(AppLocalizations.of(context).tr('chat.title'));

                String content;

                switch (connectionState) {
                  case ChatConnectionState.CONNECTED:
                    content = AppLocalizations.of(context)
                        .tr('chat.connection.connected');
                    break;
                  case ChatConnectionState.CONNECTING:
                    content = AppLocalizations.of(context)
                        .tr('chat.connection.connecting');
                    break;
                  case ChatConnectionState.DISCONNECTED:
                    content = AppLocalizations.of(context)
                        .tr('chat.connection.disconnected');
                    break;
                }

                var topicStyle = UISkin.of(context).appSkin.topicTextStyle;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[title, Text(content, style: topicStyle)],
                );
              });
        } else {
          var network = networkListBloc.findNetworkWithChannel(channel);

          return Provider(
              providable: NetworkChannelBloc(
                  backendService, network, channel, channelsStateBloc),
              child: IRCNetworkChannelTopicTitleWidget());
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    var activeChannelBloc = Provider.of<IRCChatActiveChannelBloc>(context);
    var backendService = Provider.of<ChatInputBackendService>(context);
    var networkListBloc = Provider.of<ChatNetworksListBloc>(context);
    var channelsStateBloc = Provider.of<ChatNetworkChannelsStateBloc>(context);

    return SafeArea(
        child: StreamBuilder<NetworkChannel>(
            stream: activeChannelBloc.activeChannelStream,
            builder:
                (BuildContext context, AsyncSnapshot<NetworkChannel> snapshot) {
              var channel = snapshot.data;
              if (channel == null) {
                return StreamBuilder<bool>(
                  stream: networkListBloc.isNetworksEmptyStream,
                  initialData: networkListBloc.isNetworksEmpty,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var isEmpty = snapshot.data;
                    if (isEmpty) {
                      return _buildConnectToNetworkWidget(context);
                    } else {
                      return _buildNoActiveChannelMessage(context);
                    }
                  },
                );
              } else {
                var network = networkListBloc.findNetworkWithChannel(channel);

                return Provider(
                    providable: NetworkChannelBloc(
                        backendService, network, channel, channelsStateBloc),
                    child: IRCNetworkChannelWidget());
              }
            }));
  }

  Widget _buildConnectToNetworkWidget(BuildContext context) {
    var connectionBloc = Provider.of<ChatConnectionBloc>(context);
    return StreamBuilder<ChatConnectionState>(
        stream: connectionBloc.connectionStateStream,
        initialData: connectionBloc.connectionState,
        builder: (BuildContext context,
            AsyncSnapshot<ChatConnectionState> snapshot) {
          var connectionState = snapshot.data;
          switch (connectionState) {
            case ChatConnectionState.CONNECTED:
              var startValues = createDefaultIRCNetworkPreferences(context);
              return Provider(
                providable: IRCNetworkPreferencesFormBloc(startValues),
                child: IRCNetworkPreferencesFormWidget(startValues,
                    (context, preferences) async {
                  var networksBloc = Provider.of<ChatNetworksListBloc>(context);
                  await networksBloc.joinNetwork(preferences);
                }),
              );
              break;
            case ChatConnectionState.CONNECTING:
              return Center(child: Text("Connecting to server"));
              break;
            case ChatConnectionState.DISCONNECTED:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Not connected to server"),
                    PlatformButton(
                        child: Text("Reconnect"),
                        onPressed: () {
                          connectionBloc.reconnect();
                        })
                  ],
                ),
              );
              break;
          }
          throw Exception("Invalid Chat connection state $connectionState");
        });
  }

  Center _buildNoActiveChannelMessage(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).tr('chat.no_active_channel')),
    );
  }
}
