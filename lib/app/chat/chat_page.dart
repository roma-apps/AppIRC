import 'package:flutter/material.dart'
    show AppBar, Colors, Drawer, Icons, ScaffoldState;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu.dart';
import 'package:flutter_appirc/app/channel/list/unread_count/channel_list_unread_count_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/db/chat_database_service.dart';
import 'package:flutter_appirc/app/chat/drawer/chat_drawer_page.dart';
import 'package:flutter_appirc/app/chat/drawer/chat_drawer_widget.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_bloc.dart';
import 'package:flutter_appirc/app/chat/init/chat_init_model.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_bloc.dart';
import 'package:flutter_appirc/app/chat/search/chat_search_page.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/message_loader_bloc.dart';
import 'package:flutter_appirc/app/message/message_manager_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_widget.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:flutter_appirc/disposable/disposable_provider.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("chat_page.dart");

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();

  const ChatPage();
}

class _ChatPageState extends State<ChatPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext outerContext) {
    var platformProviderState = PlatformProvider.of(context);

    switch (platformProviderState.platform) {
      case TargetPlatform.android:
        return buildPlatformScaffold(
          context,
          material: (context, platform) => MaterialScaffoldData(
            widgetKey: _scaffoldKey,
            appBar: AppBar(
              title: _ChatPageAppBarChild(),
              leading: _ChatPageAppBarLeadingWidget(
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              actions: <Widget>[
                _ChatPageAppBarTrailingWidget(),
              ],
            ),
            drawer: Drawer(
              child: ChatDrawerWidget(),
            ),
            body: _ChatPageBodyWidget(),
          ),
        );
        break;
      case TargetPlatform.iOS:
        return buildPlatformScaffold(
          context,
          iosContentBottomPadding: true,
          iosContentPadding: true,
          appBar: PlatformAppBar(
            leading: _ChatPageAppBarLeadingWidget(
              onPressed: () {
                Navigator.push(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (context) => ChatDrawerPage(),
                  ),
                );
              },
            ),
            trailingActions: [
              _ChatPageAppBarTrailingWidget(),
            ],
            title: _ChatPageAppBarChild(),
          ),
          body: _ChatPageBodyWidget(),
        );
        break;
      default:
        throw "NotSupportedPlatform";
    }
  }
}

class _ChatPageNoActiveChannelWidget extends StatelessWidget {
  const _ChatPageNoActiveChannelWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        S.of(context).chat_state_active_channel_not_selected,
        style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
      ),
    );
  }
}

class _ChatPageConnectionWidget extends StatelessWidget {
  const _ChatPageConnectionWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var connectionBloc = Provider.of<ChatConnectionBloc>(context);

    return StreamBuilder<ChatConnectionState>(
      stream: connectionBloc.connectionStateStream,
      initialData: connectionBloc.connectionState,
      builder:
          (BuildContext context, AsyncSnapshot<ChatConnectionState> snapshot) {
        var connectionState = snapshot.data;
        switch (connectionState) {
          case ChatConnectionState.connected:
            return _buildConnectedWidget(context);

            break;
          case ChatConnectionState.connecting:
            return _buildConnectingWidget(context);
            break;
          case ChatConnectionState.disconnected:
            return _buildDisconnectedWidget(context);
            break;
        }
        throw Exception("Invalid Chat connection state $connectionState");
      },
    );
  }

  Widget _buildDisconnectedWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            S.of(context).chat_state_connection_status_disconnected,
            style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
          ),
          PlatformButton(
            child: Text(S.of(context).chat_state_connection_action_reconnect),
            onPressed: () {
              var connectionBloc = Provider.of<ChatConnectionBloc>(
                context,
                listen: false,
              );
              connectionBloc.reconnect();
            },
          )
        ],
      ),
    );
  }

  Widget _buildConnectedWidget(BuildContext context) {
    var initBloc = Provider.of<ChatInitBloc>(context);

    _logger.fine(() => "_buildConnectedWidget");

    return StreamBuilder<ChatInitState>(
      stream: initBloc.stateStream,
      initialData: initBloc.state,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var currentInitState = snapshot.data;
        _logger.fine(() => "currentInitState $currentInitState");
        if (currentInitState == ChatInitState.finished) {
          return _buildConnectedInitFinishedWidget(context);
        } else {
          return _buildInitMessagesWidget(context);
        }
      },
    );
  }

  Widget _buildInitMessagesWidget(BuildContext context) =>
      _ChatPageLoadingWidget(
        message: S.of(context).chat_state_init,
      );

  Widget _buildConnectingWidget(BuildContext context) => _ChatPageLoadingWidget(
        message: S.of(context).chat_state_connection_status_connecting,
      );

  Widget _buildConnectedInitFinishedWidget(BuildContext context) {
    ChatBackendService backendService = Provider.of(context);
    var startValues =
        backendService.chatConfig.createDefaultNetworkPreferences();
    NetworkListBloc networkListBloc = Provider.of(context);
    return DisposableProvider<NetworkPreferencesFormBloc>(
      create: (context) => NetworkPreferencesFormBloc(
        preferences: startValues,
        isNeedShowChannels: true,
        isNeedShowCommands: false,
        serverPreferencesEnabled: !backendService.chatConfig.lockNetwork,
        serverPreferencesVisible: backendService.chatConfig.displayNetwork,
        networkValidator: buildNetworkValidator(
          networkListBloc,
        ),
      ),
      child: NetworkPreferencesFormWidget(
        startValues,
        (context, preferences) async {
          var networksBloc = Provider.of<NetworkListBloc>(
            context,
            listen: false,
          );
          await networksBloc.joinNetwork(
            preferences,
          );
        },
        S.of(context).irc_connection_new_action_connect,
      ),
    );
  }
}

class _ChatPageLoadingWidget extends StatelessWidget {
  final String message;

  _ChatPageLoadingWidget({
    @required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: IAppIrcUiTextTheme.of(context).mediumDarkGrey,
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _ChatPageAppBarChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);
    var connectionBloc = Provider.of<ChatConnectionBloc>(context);

    return StreamBuilder<Channel>(
      stream: activeChannelBloc.activeChannelStream,
      builder:
          (BuildContext context, AsyncSnapshot<Channel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return StreamBuilder<ChatConnectionState>(
            stream: connectionBloc.connectionStateStream,
            initialData: connectionBloc.connectionState,
            builder: (BuildContext context,
                AsyncSnapshot<ChatConnectionState> snapshot) {
              var connectionState = snapshot.data;

              var title = S.of(context).chat_title;

              String content;

              switch (connectionState) {
                case ChatConnectionState.connected:
                  content =
                      S.of(context).chat_state_connection_status_connected;
                  break;
                case ChatConnectionState.connecting:
                  content =
                      S.of(context).chat_state_connection_status_connecting;
                  break;
                case ChatConnectionState.disconnected:
                  content =
                      S.of(context).chat_state_connection_status_disconnected;
                  break;
              }

              return ChatAppBarWidget(title, content);
            },
          );
        } else {
          var channelBloc =
              ChannelBlocsBloc.of(context).getChannelBloc(channel);

          var networkBlocsBloc = NetworkBlocsBloc.of(context);

          var networkBloc =
              networkBlocsBloc.getNetworkBloc(channelBloc.network);

          return Provider.value(
            value: networkBloc,
            child: Provider.value(
              value: channel,
              child: Provider.value(
                value: channelBloc,
                child: const ChannelTopicTitleAppBarWidget(),
              ),
            ),
          );
        }
      },
    );
  }
}

class _ChatPageAppBarTrailingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    var platformProviderState = PlatformProvider.of(context);

    return StreamBuilder<Channel>(
      stream: activeChannelBloc.activeChannelStream,
      builder:
          (BuildContext context, AsyncSnapshot<Channel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return const SizedBox.shrink();
        } else {
          var channelBloc =
              ChannelBlocsBloc.of(context).getChannelBloc(channel);

          List<Widget> items = [
            ChannelPopupMenuButtonWidget(
              iconColor: null,
              isNeedPadding:
                  platformProviderState.platform != TargetPlatform.iOS,
            ),
          ];

          items.insert(
            0,
            PlatformIconButton(
              padding: platformProviderState.platform == TargetPlatform.iOS
                  ? EdgeInsets.zero
                  : EdgeInsets.all(8.0),
              icon: Icon(
                Icons.search,
                // color: IAppIrcUiColorTheme.of(context).white,
              ),
              onPressed: () {
                _goToSearchPage(context, channel, channelBloc);
              },
            ),
          );

          var networkBloc =
              NetworkBlocsBloc.of(context).getNetworkBloc(channelBloc.network);

          return Provider.value(
            value: channel,
            child: Provider.value(
              value: channelBloc.network,
              child: Provider.value(
                value: channelBloc,
                child: Provider.value(
                  value: networkBloc,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: items,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class _ChatPageAppBarLeadingWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const _ChatPageAppBarLeadingWidget({
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ChannelListUnreadCountBloc chatUnreadBloc =
        Provider.of<ChannelListUnreadCountBloc>(context);

    var platformProviderState = PlatformProvider.of(context);

    return StreamBuilder<int>(
      stream: chatUnreadBloc.channelsWithUnreadMessagesCountStream,
      initialData: chatUnreadBloc.channelsWithUnreadMessagesCount,
      builder: (context, snapshot) {
        var unreadCount = snapshot.data;

        var platformIconButton = PlatformIconButton(
          padding: platformProviderState.platform == TargetPlatform.iOS
              ? EdgeInsets.zero
              : EdgeInsets.all(8.0),
          icon: Icon(
            Icons.menu,
            // color: IAppIrcUiColorTheme.of(context).white,
          ),
          onPressed: onPressed,
        );
        if (unreadCount > 0) {
          // badge hide part of button clickable area
          double rightMargin = 15.0;

          if (isMaterial(context)) {
            rightMargin = 15;
          } else if (isCupertino(context)) {
            rightMargin = 5;
          }
          return GestureDetector(
            onTap: onPressed,
            child: Stack(children: <Widget>[
              platformIconButton,
              Positioned(
                right: rightMargin,
                top: 10,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    "$unreadCount",
                    style: TextStyle(
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
      },
    );
  }
}

void _goToSearchPage(
  BuildContext context,
  Channel channel,
  ChannelBloc channelBloc,
) {
  ChatDatabaseService databaseProvider = Provider.of(
    context,
    listen: false,
  );

  Navigator.push(
    context,
    platformPageRoute(
      context: context,
      builder: (context) {
        return DisposableProvider<ChatSearchBloc>(
          create: (context) => ChatSearchBloc(
            databaseProvider.chatDatabase,
            channel,
          ),
          child: Provider.value(
            value: channelBloc,
            child: ChatSearchPage(),
          ),
        );
      },
    ),
  );
}

class _ChatPageBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    return SafeArea(
      child: StreamBuilder<Channel>(
        stream: activeChannelBloc.activeChannelStream,
        builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
          var activeChannel = snapshot.data;

          return Provider.value(
            value: activeChannel,
            child: Column(
              children: [
                _ChatPageBodyPublicModeReconnectWidget(),
                Expanded(child: _ChatPageBodyActiveChannelWidget()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatPageBodyPublicModeReconnectWidget extends StatelessWidget {
  const _ChatPageBodyPublicModeReconnectWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loungeBackendService = Provider.of<LoungeBackendService>(context);

    return StreamBuilder<bool>(
      stream: loungeBackendService.isPublicModeAndDisconnectedStream,
      initialData: loungeBackendService.isPublicModeAndDisconnected,
      builder: (context, snapshot) {
        var isPublicModeAndDisconnected = snapshot.data;
        if (isPublicModeAndDisconnected) {
          return Container(
            decoration: BoxDecoration(
              color: IAppIrcUiColorTheme.of(context).error,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          S
                              .of(context)
                              .chat_connection_public_reconnectNotSupported_description,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: IAppIrcUiTextTheme.of(context).bigTallWhite,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PlatformButton(
                        child: Text(
                          S
                              .of(context)
                              .chat_connection_public_reconnectNotSupported_action_restart,
                        ),
                        onPressed: () {
                          loungeBackendService.restart();
                        },
                      ),
                      PlatformButton(
                        child: Text(
                          S
                              .of(context)
                              .chat_connection_public_reconnectNotSupported_action_signOut,
                        ),
                        onPressed: () {
                          loungeBackendService.signOut();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _ChatPageBodyActiveChannelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var activeChannel = Provider.of<Channel>(context);

    var networkListBloc = Provider.of<NetworkListBloc>(context);

    _logger.fine(() => "activeChannel $activeChannel");
    if (activeChannel == null) {
      return const _ChatPageBodyNoActiveChannelWidget();
    } else {
      var network = networkListBloc.findNetworkWithChannel(activeChannel);

      if (network == null) {
        return const SizedBox.shrink();
      } else {
        var channelBlocsBloc = ChannelBlocsBloc.of(context);

        return ProxyProvider<Channel, ChannelBloc>(
          update: (context, channel, _) =>
              channelBlocsBloc.getChannelBloc(activeChannel),
          child: _ChatPageBodyActiveChannelBodyWidget(),
        );
      }
    }
  }
}

class _ChatPageBodyActiveChannelBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = ChannelBloc.of(context);

    ChatBackendService backendService = Provider.of(context);
    ChatDatabaseService chatDatabaseService = Provider.of(context);

    _logger.fine(() => "before stream");
    return DisposableProxyProvider<ChannelBloc, MessageLoaderBloc>(
      update: (context, channelBloc, _) => MessageLoaderBloc(
        backendService: backendService,
        db: chatDatabaseService.chatDatabase,
        messagesSaverBloc:
            Provider.of<MessageManagerBloc>(context, listen: false),
        network: channelBloc.network,
        channel: channelBloc.channel,
        channelBloc: channelBloc,
      ),
      child: Builder(
        builder: (context) {
          var messagesLoaderBloc = Provider.of<MessageLoaderBloc>(context);
          return StreamBuilder(
            stream: messagesLoaderBloc.isInitFinishedStream,
            initialData: false,
            builder: (context, snapshot) {
              var initFinished = snapshot.data;
              var length = messagesLoaderBloc.messagesList?.allMessages?.length;
              _logger.fine(() => "initFinished $initFinished "
                  "messages $length");
              if (initFinished && length != null) {
                _logger.fine(() =>
                    "build for activeChannel ${channelBloc.channel.name}");

                return DisposableProxyProvider<MessageLoaderBloc,
                    MessageListBloc>(
                  update: (context, messagesLoaderBloc, _) => MessageListBloc(
                    messagesLoaderBloc.channelBloc,
                    messagesLoaderBloc.channelBloc.messagesBloc,
                    messagesLoaderBloc,
                    Provider.of<MessageCondensedBloc>(
                      context,
                      listen: false,
                    ),
                  ),
                  child: ChannelWidget(),
                );
              } else {
                return _ChatPageLoadingWidget(
                  message: S.of(context).chat_messages_list_loading,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _ChatPageBodyNoActiveChannelWidget extends StatelessWidget {
  const _ChatPageBodyNoActiveChannelWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var networkListBloc = Provider.of<NetworkListBloc>(context);
    return StreamBuilder<bool>(
      stream: networkListBloc.isNetworksEmptyStream,
      initialData: networkListBloc.isNetworksEmpty,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var isEmpty = snapshot.data;
        if (isEmpty) {
          return const _ChatPageConnectionWidget();
        } else {
          return const _ChatPageNoActiveChannelWidget();
        }
      },
    );
  }
}
