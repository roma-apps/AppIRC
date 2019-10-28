import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show AppBar, Colors, Drawer, Icons, ScaffoldState;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
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
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/message_loader_bloc.dart';
import 'package:flutter_appirc/app/message/message_saver_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_widget.dart';
import 'package:flutter_appirc/app/skin/themes/app_irc_skin_theme.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/skin_model.dart';
import 'package:flutter_appirc/skin/skin_preference_bloc.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

var _logger = MyLogger(logTag: "chat_page.dart", enabled: true);

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
    ChannelListUnreadCountBloc chatUnreadBloc = Provider.of<ChannelListUnreadCountBloc>(context);

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

            if (isMaterial) {
              rightMargin = 15;
            } else if (isCupertino) {
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
      builder: (BuildContext context,
          AsyncSnapshot<Channel> activeChannelSnapshot) {
        var channel = activeChannelSnapshot.data;
        if (channel == null) {
          return SizedBox.shrink();
        } else {
          var networkListBloc = Provider.of<NetworkListBloc>(context);

          var network = networkListBloc.findNetworkWithChannel(channel);

          var networkBloc =
              NetworkBlocsBloc.of(context).getNetworkBloc(network);

          var channelBloc = ChannelBlocsBloc.of(context)
              .getChannelBloc(channel);

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

    return StreamBuilder<Channel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context,
          AsyncSnapshot<Channel> activeChannelSnapshot) {
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
                  case ChatConnectionState.connected:
                    content = AppLocalizations.of(context)
                        .tr('chat.state.connection.status.connected');
                    break;
                  case ChatConnectionState.connecting:
                    content = AppLocalizations.of(context)
                        .tr('chat.state.connection.status.connecting');
                    break;
                  case ChatConnectionState.disconnected:
                    content = AppLocalizations.of(context)
                        .tr('chat.state.connection.status.disconnected');
                    break;
                }

                return ChatAppBarWidget(title, content);
              });
        } else {
          var channelBloc = ChannelBlocsBloc.of(context)
              .getChannelBloc(channel);
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

    return SafeArea(
        child: StreamBuilder<Channel>(
            stream: activeChannelBloc.activeChannelStream,
            builder:
                (BuildContext context, AsyncSnapshot<Channel> snapshot) {
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
                  var channelBloc = ChannelBlocsBloc.of(context)
                      .getChannelBloc(activeChannel);

                  ChatBackendService backendService = Provider.of(context);
                  ChatDatabaseProvider chatDatabaseProvider =
                      Provider.of(context);

                  var messagesLoaderBloc = MessageLoaderBloc(
                      backendService,
                      chatDatabaseProvider.db,
                      Provider.of<MessageSaverBloc>(context),
                      channelBloc.network,
                      channelBloc.channel);

                  return Provider(
                    providable: messagesLoaderBloc,
                    child: StreamBuilder(
                        stream: messagesLoaderBloc.isInitFinishedStream,
                        initialData: false,
                        builder: (context, snapshot) {
                          var initFinished = snapshot.data;
                          var length = messagesLoaderBloc.messages?.length;
                          _logger.d(() => "initFinished $initFinished "
                              "messages $length");
                          if (initFinished && length != null) {
                            var chatListMessagesBloc = MessageListBloc(
                                channelBloc.messagesBloc,
                                messagesLoaderBloc,
                                channelBloc);

                            _logger.d(() =>
                                "build for activeChannel ${channelBloc.channel.name}");


                            return Provider(
                                providable:
                                    ChannelBlocProvider(channelBloc),
                                child: Provider(
                                  providable: chatListMessagesBloc,
                                  child: ChannelWidget(),
                                ));
                          } else {
                            return Center(
                                child: _buildLoadingMessagesWidget(context));
                          }
                        }),
                  );
                }
              }
            }));
  }

  Text _buildLoadingMessagesWidget(BuildContext context) =>
      Text(AppLocalizations.of(context).tr("chat.messages_list.loading"));

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
    var appLocalizations = AppLocalizations.of(context);
    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
              appLocalizations.tr("chat.state.connection"
                  ".status.disconnected"),
              style: textSkinBloc.defaultTextStyle),
          createSkinnedPlatformButton(context,
              child: Text(appLocalizations.tr(
                  "chat.state.connection.action.reconnect")), onPressed: () {
            var connectionBloc = Provider.of<ChatConnectionBloc>(context);
            connectionBloc.reconnect();
          })
        ],
      ),
    );
  }

  Widget _buildConnectingWidget(BuildContext context) {
    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
        child: Text(
            AppLocalizations.of(context)
                .tr("chat.state.connection.status.connecting"),
            style: textSkinBloc.defaultTextStyle));
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
            return _buildConnectedAlreadyInitWidget(context);
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildConnectedNoInitWidget(),
                ),
                _buildLoadingMessagesWidget(context)
              ],
            );
          }
        });
  }

  Widget _buildConnectedNoInitWidget() =>
      Center(child: PlatformCircularProgressIndicator());

  Widget _buildConnectedAlreadyInitWidget(BuildContext context) {
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
      }, AppLocalizations.of(context).tr('irc.connection.new.action.connect')),
    );
  }

  Center _buildNoActiveChannelMessage(BuildContext context) {
    TextSkinBloc textSkinBloc = Provider.of(context);
    return Center(
        child: Text(
      AppLocalizations.of(context).tr('chat.state.active_channel_not_selected'),
      style: textSkinBloc.defaultTextStyle,
    ));
  }
}
