import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show AppBar, Colors, Drawer, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu_widget.dart';
import 'package:flutter_appirc/app/channel/channel_topic_widget.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_drawer_page.dart';
import 'package:flutter_appirc/app/chat/chat_drawer_widget.dart';
import 'package:flutter_appirc/app/chat/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_states_bloc.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_widget.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/app/user/users_list_page.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_model.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppSkinPreferenceBloc<AppIRCSkinTheme> skinPreferenceBloc =
        Provider.of<AppSkinPreferenceBloc<AppIRCSkinTheme>>(context);

    return StreamBuilder<AppSkinTheme>(
        initialData: skinPreferenceBloc.currentAppSkinTheme,
        stream: skinPreferenceBloc.appSkinStream,
        builder: (context, asyncSnapshot) {
          AppIRCSkinTheme currentSkin = asyncSnapshot.data;



          return PlatformScaffold(
              android: (context) => MaterialScaffoldData(
                  appBar: AppBar(
                    title: _buildAppBarChild(context),
                    actions: <Widget>[
                      _buildTrailing(context),
                    ],
                    backgroundColor: currentSkin.appBarColor,
                  ),
                  drawer: Drawer(child: ChatDrawerWidget()),
                  body: _buildBody(context)),
              ios: (context) => CupertinoPageScaffoldData(
                  resizeToAvoidBottomInset: true,
                  body: _buildBody(context),
                  navigationBar: CupertinoNavigationBar(
                    leading: PlatformIconButton(
                      icon: _buildMenuIcon(context),
                      onPressed: () {
                        Navigator.push(
                            context,
                            platformPageRoute(
                                builder: (context) => ChatDrawerPage()));
                      },
                    ),
                    trailing: _buildTrailing(context),
                    middle: _buildAppBarChild(context),
                  )));
        });
  }

  Icon _buildMenuIcon(BuildContext context) => Icon(Icons.menu,
      color: Provider.of<ChatAppBarSkinBloc>(context).iconAppBarColor);

  Widget _buildTrailing(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    return StreamBuilder<NetworkChannel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context,
          AsyncSnapshot<NetworkChannel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return SizedBox.shrink();
        } else {

          var networkListBloc = Provider.of<ChatNetworksListBloc>(context);

          var network = networkListBloc.findNetworkWithChannel(channel);

          var networkBloc =
              ChatNetworksBlocsBloc.of(context).getNetworkBloc(network);

          var channelBloc = ChatNetworkChannelsBlocsBloc.of(context)
              .getNetworkChannelBloc(channel);

          List<Widget> items = [
            buildChannelPopupMenuButton(context, networkBloc, channelBloc,
                Provider.of<ChatAppBarSkinBloc>(context).iconAppBarColor)
          ];

          if (channel.type == NetworkChannelType.CHANNEL) {
            items.add(PlatformIconButton(
                icon: Icon(Icons.group,
                    color: Provider.of<ChatAppBarSkinBloc>(context)
                        .iconAppBarColor),
                onPressed: () {
                  Navigator.push(
                      context,
                      platformPageRoute(
                          builder: (context) =>
                              NetworkChannelUsersPage(network, channel)));
                }));
          }

          return Row(
              mainAxisSize: MainAxisSize.min,
              children: items);
        }
      },
    );
  }

  Widget _buildAppBarChild(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);
    var connectionBloc = Provider.of<ChatConnectionBloc>(context);

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

                var title = AppLocalizations.of(context).tr('chat.title');

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

                return ChatAppBarWidget(title, content);
              });
        } else {
          var channelBloc = ChatNetworkChannelsBlocsBloc.of(context)
              .getNetworkChannelBloc(channel);
          return Provider(
              providable: channelBloc,
              child: NetworkChannelTopicTitleAppBarWidget());
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);
    var networkListBloc = Provider.of<ChatNetworksListBloc>(context);


    return SafeArea(
        child: StreamBuilder<NetworkChannel>(
            stream: activeChannelBloc.activeChannelStream,
            builder:
                (BuildContext context, AsyncSnapshot<NetworkChannel> snapshot) {
              var activeChannel = snapshot.data;
              if (activeChannel == null) {


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
                var network = networkListBloc.findNetworkWithChannel(activeChannel);

                if (network == null) {
                  return SizedBox.shrink();
                } else {
                  var channelBloc = ChatNetworkChannelsBlocsBloc.of(context)
                      .getNetworkChannelBloc(activeChannel);

                  return Provider(
                    providable: channelBloc,
                    child: Provider(
                        providable: channelBloc, child: NetworkChannelWidget()),
                  );
                }
              }
            }));
  }

  Widget _buildConnectToNetworkWidget(BuildContext context) {
    var connectionBloc = Provider.of<ChatConnectionBloc>(context);
    ChatBackendService backendService = Provider.of(context);
    return StreamBuilder<ChatConnectionState>(
        stream: connectionBloc.connectionStateStream,
        initialData: connectionBloc.connectionState,
        builder: (BuildContext context,
            AsyncSnapshot<ChatConnectionState> snapshot) {
          var connectionState = snapshot.data;
          var appLocalizations = AppLocalizations.of(context);
          switch (connectionState) {
            case ChatConnectionState.CONNECTED:


              var initBloc = Provider.of<ChatInitBloc>(context);

              return StreamBuilder<ChatInitState>(   stream: initBloc.stateStream,
                  initialData: initBloc.state,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var currentInitState = snapshot.data;

                    if(currentInitState == ChatInitState.FINISHED) {
                      var startValues = createDefaultNetworkPreferences(context);
                      return Provider(
                        providable:
                        ChatNetworkPreferencesFormBloc(startValues, true,
                          false, !backendService.chatConfig.lockNetwork,
                            backendService.chatConfig.displayNetwork),
                        child: ChatNetworkPreferencesFormWidget(startValues,
                                (context, preferences) async {
                              var networksBloc = Provider.of<ChatNetworksListBloc>(context);
                              await networksBloc.joinNetwork(preferences);
                            }, AppLocalizations.of(context).tr('irc_connection.connect')),
                      );
                    } else {
                      return Center(child: PlatformCircularProgressIndicator());
                    }

                  });

              break;
            case ChatConnectionState.CONNECTING:
              return Center(
                  child:
                      Text(appLocalizations.tr("chat.connection.connecting"), style: TextStyle(
                          color:
                          AppSkinBloc.of(context).appSkinTheme.textColor)));
              break;
            case ChatConnectionState.DISCONNECTED:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(appLocalizations.tr("chat.connection.disconnected"), style: TextStyle(
                        color:
                        AppSkinBloc.of(context).appSkinTheme.textColor)),
                    createSkinnedPlatformButton(context,
                        child: Text(
                            appLocalizations.tr("chat.connection.reconnect")),
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
      child: Text(AppLocalizations.of(context).tr('chat.no_active_channel'), style: TextStyle(
          color:
          AppSkinBloc.of(context).appSkinTheme.textColor)),
    );
  }
}
