import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show AppBar, Colors, Drawer, Icons, Scaffold, ScaffoldState;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu_widget.dart';
import 'package:flutter_appirc/app/channel/channel_topic_app_bar_widget.dart';
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
import 'package:flutter_appirc/app/chat/chat_messages_loader_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_messages_saver_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_blocs_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_unread_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_widget.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_model.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'chat_messages_list_bloc.dart';

var _logger = MyLogger(logTag: "ChatPage", enabled: true);

class ChatPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext outerContext) {
    AppSkinPreferenceBloc<AppIRCSkinTheme> skinPreferenceBloc =
        Provider.of<AppSkinPreferenceBloc<AppIRCSkinTheme>>(outerContext);

    return StreamBuilder<AppSkinTheme>(
        initialData: skinPreferenceBloc.currentAppSkinTheme,
        stream: skinPreferenceBloc.appSkinStream,
        builder: (context, asyncSnapshot) {
          AppIRCSkinTheme currentSkin = asyncSnapshot.data;

          return PlatformScaffold(
              //            key: _scaffoldKey,
//            widgetKey: _scaffoldKey,
              android: (context) => MaterialScaffoldData(
                  widgetKey: _scaffoldKey,
                  appBar: AppBar(
                    title: _buildAppBarChild(context),
                    leading: buildLeading(context, () {
                      _scaffoldKey.currentState.openDrawer();
                    }),
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
                    leading: buildLeading(context, () {
                      Navigator.push(
                          context,
                          platformPageRoute(
                              builder: (context) => ChatDrawerPage()));
                    }),
                    trailing: _buildTrailing(context),
                    middle: _buildAppBarChild(context),
                  )));
        });
  }

  Widget buildLeading(BuildContext context, Function() onPressed) {
    return _buildMenuIcon(context, onPressed);
  }

  Widget _buildMenuIcon(BuildContext context, Function() onPressed) {
    ChatUnreadBloc chatUnreadBloc = Provider.of<ChatUnreadBloc>(context);

    return StreamBuilder<int>(
        stream: chatUnreadBloc.channelsWithUnreadMessagesCountStream,
        initialData: chatUnreadBloc.channelsWithUnreadMessagesCount,
        builder: (context, snapshot) {
          var unreadCount = snapshot.data;

          var platformIconButton = PlatformIconButton(
            icon: Icon(Icons.menu,
                color:
                    Provider.of<ChatAppBarSkinBloc>(context).iconAppBarColor),
            onPressed: onPressed,
          );
          if (unreadCount > 0) {
            // badge hide part of button clickable area
            double rightMargin = 15.0;

            if(isMaterial) {
              rightMargin = 15;
            } else if(isCupertino) {
              rightMargin = 5;
            }
            return GestureDetector(
              onTap: onPressed,
              child: Stack(children: <Widget>[
                platformIconButton,
                new Positioned(
                  right: rightMargin,
                  top: 10,
                  child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: new Text(
                      "$unreadCount",
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ]),
            );
          } else {
            return platformIconButton;
          }
        });
  }

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

          items.insert(
              0,
              PlatformIconButton(
                  icon: Icon(Icons.search,
                      color: Provider.of<ChatAppBarSkinBloc>(context)
                          .iconAppBarColor),
                  onPressed: () {
                    channelBloc.messagesBloc.onNeedToggleSearch();
                  }));

          return Row(mainAxisSize: MainAxisSize.min, children: items);
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
              providable: NetworkChannelBlocProvider(channelBloc),
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
                var network =
                    networkListBloc.findNetworkWithChannel(activeChannel);

                if (network == null) {
                  return SizedBox.shrink();
                } else {
                  var channelBloc = ChatNetworkChannelsBlocsBloc.of(context)
                      .getNetworkChannelBloc(activeChannel);

                  ChatOutputBackendService backendService =
                      Provider.of(context);
                  ChatDatabaseProvider chatDatabaseProvider =
                      Provider.of(context);

                  var messagesLoaderBloc = NetworkChannelMessagesLoaderBloc(
                      backendService,
                      chatDatabaseProvider.db,
                      Provider.of<NetworkChannelMessagesSaverBloc>(context),
                      channelBloc.network,
                      channelBloc.channel);

                  var chatListMessagesBloc = ChatMessagesListBloc(
                      channelBloc.messagesBloc, messagesLoaderBloc,
                      channelBloc.channel);

                  _logger.d(() => "build for activeChannel ${channelBloc
                      .channel.name}");

                  return Provider(
                      providable: NetworkChannelBlocProvider(channelBloc),
                      child: Provider(
                        providable: messagesLoaderBloc,
                        child: Provider(
                          providable: chatListMessagesBloc,
                          child: NetworkChannelWidget((minIndex, maxIndex) {
                            chatListMessagesBloc.onMessagesScrolled(
                                minIndex, maxIndex);
                          }),
                        ),
                      ));
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

              return StreamBuilder<ChatInitState>(
                  stream: initBloc.stateStream,
                  initialData: initBloc.state,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var currentInitState = snapshot.data;

                    if (currentInitState == ChatInitState.FINISHED) {
                      var startValues =
                          createDefaultNetworkPreferences(context);
                      return Provider(
                        providable: ChatNetworkPreferencesFormBloc(
                            startValues,
                            true,
                            false,
                            !backendService.chatConfig.lockNetwork,
                            backendService.chatConfig.displayNetwork),
                        child: ChatNetworkPreferencesFormWidget(startValues,
                            (context, preferences) async {
                          var networksBloc =
                              Provider.of<ChatNetworksListBloc>(context);
                          await networksBloc.joinNetwork(preferences);
                        },
                            AppLocalizations.of(context)
                                .tr('irc_connection.connect')),
                      );
                    } else {
                      return Center(child: PlatformCircularProgressIndicator());
                    }
                  });

              break;
            case ChatConnectionState.CONNECTING:
              return Center(
                  child: Text(appLocalizations.tr("chat.connection.connecting"),
                      style: TextStyle(
                          color:
                              AppSkinBloc.of(context).appSkinTheme.textColor)));
              break;
            case ChatConnectionState.DISCONNECTED:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(appLocalizations.tr("chat.connection.disconnected"),
                        style: TextStyle(
                            color: AppSkinBloc.of(context)
                                .appSkinTheme
                                .textColor)),
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
      child: Text(AppLocalizations.of(context).tr('chat.no_active_channel'),
          style:
              TextStyle(color: AppSkinBloc.of(context).appSkinTheme.textColor)),
    );
  }
}
