import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    show AppBar, Colors, Drawer, Icons, ScaffoldState;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_popup_menu.dart';
import 'package:flutter_appirc/app/channel/list/unread_count/channel_list_unread_count_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/db/chat_database.dart';
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
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/platform_aware/platform_aware.dart'
    as platform_aware;
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_model.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "chat_page.dart", enabled: true);

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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

          // TODO: remove hack and report bug to library
          // it is for very strange bug in
          // PlatformScaffold from PlatformAware library
          // and any TextField with software keyboard popup
          // Bug occurs when PlatformScaffold with ios key is used
          // In this case textfield loose focus on keyboard shown
          // so keyboard disappears once after appearing
          // So I decided to separate platform Scaffolds via if-else
          // PlatformScaffold without custom ios key works good on iOS
          // and keyboard appears as excepted
          if (platform_aware.isMaterial) {
            return buildPlatformScaffold(
                context,
                material: (context, platform) => MaterialScaffoldData(
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
                    body: _buildBody(context)));
          } else if (platform_aware.isCupertino) {
            return buildPlatformScaffold(
                context,
                iosContentBottomPadding: true,
                iosContentPadding: false,
                appBar: PlatformAppBar(
                  leading: buildLeading(context, () {
                    Navigator.push(
                        context,
                        platformPageRoute(
                            context: context,
                            builder: (context) => ChatDrawerPage()));
                  }),
                  trailingActions: [_buildTrailing(context)],
                  title: _buildAppBarChild(context),
                ),
                body: _buildBody(context));
          } else {
            throw "NotSupportedPlatform";
          }
        });
  }

  Widget buildLeading(BuildContext context, Function() onPressed) {
    return _buildMenuIcon(context, onPressed);
  }

  Widget _buildMenuIcon(BuildContext context, Function() onPressed) {
    ChannelListUnreadCountBloc chatUnreadBloc =
        Provider.of<ChannelListUnreadCountBloc>(context);

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

            if (isMaterial(context)) {
              rightMargin = 15;
            } else if (isCupertino(context)) {
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

    return StreamBuilder<Channel>(
      stream: activeChannelBloc.activeChannelStream,
      builder:
          (BuildContext context, AsyncSnapshot<Channel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return SizedBox.shrink();
        } else {
          var networkListBloc = Provider.of<NetworkListBloc>(context);

          var network = networkListBloc.findNetworkWithChannel(channel);

          var networkBloc =
              NetworkBlocsBloc.of(context).getNetworkBloc(network);

          var channelBloc =
              ChannelBlocsBloc.of(context).getChannelBloc(channel);

          List<Widget> items = [
            buildChannelPopupMenuButton(
                context: context,
                networkBloc: networkBloc,
                channelBloc: channelBloc,
                iconColor:
                    Provider.of<ChatAppBarSkinBloc>(context).iconAppBarColor)
          ];

          items.insert(
              0,
              PlatformIconButton(
                  icon: Icon(Icons.search,
                      color: Provider.of<ChatAppBarSkinBloc>(context)
                          .iconAppBarColor),
                  onPressed: () {
                    _goToSearchPage(context, channel, channelBloc);
                  }));

          return Row(mainAxisSize: MainAxisSize.min, children: items);
        }
      },
    );
  }

  void _goToSearchPage(BuildContext context, Channel channel, ChannelBloc channelBloc) {

    ChatDatabaseProvider databaseProvider = Provider.of(context);

    Navigator.push(
        context,
        platformPageRoute(
            context: context,
            builder: (context) {
              return Provider(
                  providable: ChatSearchBloc(databaseProvider.db, channel),
                  child: Provider(
                      providable: ChannelBlocProvider(channelBloc),
                      child: ChatSearchPage()));
            }));
  }

  Widget _buildAppBarChild(BuildContext context) {
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

                var title = tr('chat.title');

                String content;

                switch (connectionState) {
                  case ChatConnectionState.connected:
                    content = tr('chat.state.connection.status.connected');
                    break;
                  case ChatConnectionState.connecting:
                    content = tr('chat.state.connection.status.connecting');
                    break;
                  case ChatConnectionState.disconnected:
                    content = tr('chat.state.connection.status.disconnected');
                    break;
                }

                return ChatAppBarWidget(title, content);
              });
        } else {
          var channelBloc =
              ChannelBlocsBloc.of(context).getChannelBloc(channel);
          return Provider(
              providable: ChannelBlocProvider(channelBloc),
              child: ChannelTopicTitleAppBarWidget());
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);
    var networkListBloc = Provider.of<NetworkListBloc>(context);

    _logger.d(() => "_buildBody");
    return SafeArea(
        child: StreamBuilder<Channel>(
            stream: activeChannelBloc.activeChannelStream,
            builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
              var activeChannel = snapshot.data;

              _logger.d(() => "activeChannel stream");
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
                  var channelBloc = ChannelBlocsBloc.of(context)
                      .getChannelBloc(activeChannel);

                  ChatBackendService backendService = Provider.of(context);
                  ChatDatabaseProvider chatDatabaseProvider =
                      Provider.of(context);

                  var messagesLoaderBloc = MessageLoaderBloc(
                      backendService,
                      chatDatabaseProvider.db,
                      Provider.of<MessageManagerBloc>(context),
                      channelBloc.network,
                      channelBloc.channel);
                  _logger.d(() => "before stream");
                  return Provider(
                    providable: messagesLoaderBloc,
                    child: StreamBuilder(
                        stream: messagesLoaderBloc.isInitFinishedStream,
                        initialData: false,
                        builder: (context, snapshot) {
                          var initFinished = snapshot.data;
                          var length = messagesLoaderBloc
                              .messagesList?.allMessages?.length;
                          _logger.d(() => "initFinished $initFinished "
                              "messages $length");
                          if (initFinished && length != null) {
                            var chatListMessagesBloc = MessageListBloc(
                              channelBloc,
                                channelBloc.messagesBloc,
                                messagesLoaderBloc,
                                Provider.of<MessageCondensedBloc>(context));

                            _logger.d(() =>
                                "build for activeChannel ${channelBloc.channel.name}");

                            return Provider(
                                providable: ChannelBlocProvider(channelBloc),
                                child: Provider(
                                  providable: chatListMessagesBloc,
                                  child: ChannelWidget(),
                                ));
                          } else {
                            return _buildLoadingMessagesWidget(context);
                          }
                        }),
                  );
                }
              }
            }));
  }

  Widget _buildLoadingMessagesWidget(BuildContext context) {
    return _buildLoadingWidget(
        context, tr("chat.messages_list.loading"));
  }

  Widget _buildInitMessagesWidget(BuildContext context) {
    return _buildLoadingWidget(
        context, tr("chat.state.init"));
  }

  Widget _buildConnectingWidget(BuildContext context) => _buildLoadingWidget(
      context,
      tr("chat.state.connection.status.connecting"));

  Widget _buildLoadingWidget(BuildContext context, String message) {
    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(message, style: textSkinBloc.defaultTextStyle),
            ),
            CircularProgressIndicator()
          ]),
    );
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
        });
  }

  Widget _buildDisconnectedWidget(BuildContext context) {

    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
              tr("chat.state.connection"
                  ".status.disconnected"),
              style: textSkinBloc.defaultTextStyle),
          createSkinnedPlatformButton(context,
              child: Text(tr(
                  "chat.state.connection.action.reconnect")), onPressed: () {
            var connectionBloc = Provider.of<ChatConnectionBloc>(context);
            connectionBloc.reconnect();
          })
        ],
      ),
    );
  }

  Widget _buildConnectedWidget(BuildContext context) {
    var initBloc = Provider.of<ChatInitBloc>(context);

    _logger.d(() => "_buildConnectedWidget");

    return StreamBuilder<ChatInitState>(
        stream: initBloc.stateStream,
        initialData: initBloc.state,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var currentInitState = snapshot.data;
          _logger.d(() => "currentInitState $currentInitState");
          if (currentInitState == ChatInitState.finished) {
            return _buildConnectedInitFinishedWidget(context);
          } else {
            return _buildInitMessagesWidget(context);
          }
        });
  }

  Widget _buildConnectedInitFinishedWidget(BuildContext context) {
    ChatBackendService backendService = Provider.of(context);
    var startValues =
        backendService.chatConfig.createDefaultNetworkPreferences();
    NetworkListBloc networkListBloc = Provider.of(context);
    return Provider<NetworkPreferencesFormBloc>(
      providable: NetworkPreferencesFormBloc.name(
          preferences: startValues,
          isNeedShowChannels: true,
          isNeedShowCommands: false,
          serverPreferencesEnabled: !backendService.chatConfig.lockNetwork,
          serverPreferencesVisible: backendService.chatConfig.displayNetwork,
          networkValidator: buildNetworkValidator(networkListBloc)),
      child: NetworkPreferencesFormWidget(startValues,
          (context, preferences) async {
        var networksBloc = Provider.of<NetworkListBloc>(context);
        await networksBloc.joinNetwork(preferences);
      }, tr('irc.connection.new.action.connect')),
    );
  }

  Center _buildNoActiveChannelMessage(BuildContext context) {
    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
        child: Text(
      tr('chat.state.active_channel_not_selected'),
      style: textSkinBloc.defaultTextStyle,
    ));
  }
}
