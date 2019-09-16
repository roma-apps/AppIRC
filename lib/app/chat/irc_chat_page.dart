import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, AppBar, Drawer;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channels/info/irc_network_channel_topic_widget.dart';
import 'package:flutter_appirc/app/channels/info/irc_network_channel_widget.dart';
import 'package:flutter_appirc/app/channels/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/app/channels/users/irc_network_channel_users_page.dart';
import 'package:flutter_appirc/app/chat/chat_bloc.dart';
import 'package:flutter_appirc/app/chat/irc_chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/irc_chat_settings_page.dart';
import 'package:flutter_appirc/app/chat/irc_chat_settings_widget.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/local_preferences/preferences_service.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);
    var preferencesService = Provider.of<PreferencesService>(context);
    var networksListBloc = Provider.of<ChatBloc>(context);

    return Provider<IRCChatActiveChannelBloc>(
      bloc: IRCChatActiveChannelBloc(
          lounge: lounge,
          networksListBloc: networksListBloc,
          preferenceBloc:
              createActiveChannelPreferenceBloc(preferencesService)),
      child: StreamBuilder<LoungePreferences>(
          stream: lounge.loungePreferencesStream,
          builder: (context, snapshot) {
            return PlatformScaffold(
                android: (context) => MaterialScaffoldData(
                    appBar: AppBar(
                      title: _buildAppBarChild(context),
                      actions: <Widget>[
                        buildMembersButton(context),
                      ],
                    ),
                    drawer: Drawer(child: IRCChatSettingsWidget()),
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
                                  builder: (context) => IRCChatSettingsPage()));
                        },
                      ),
                      trailing: buildMembersButton(context),
                      middle: _buildAppBarChild(context),
                    )));
          }),
    );
  }

  Widget buildMembersButton(BuildContext context) {
    var activeChannelBloc = Provider.of<IRCChatActiveChannelBloc>(context);
    return StreamBuilder<IRCNetworkChannel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context,
          AsyncSnapshot<IRCNetworkChannel> activeChannelSnapshot) {
        var activeChannel = activeChannelSnapshot.data;
        if (activeChannel == null) {
          return Container();
        } else {
          return PlatformIconButton(
            androidIcon: Icon(Icons.group),
            iosIcon: Icon(CupertinoIcons.group_solid),
            onPressed: () {
              Navigator.push(
                  context,
                  platformPageRoute(
                      builder: (context) =>
                          IRCNetworkChannelUsersPage(activeChannel)));
            },
          );
        }
      },
    );
  }

  Widget _buildAppBarChild(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);

    var activeChannelBloc = Provider.of<IRCChatActiveChannelBloc>(context);

    return StreamBuilder<IRCNetworkChannel>(
      stream: activeChannelBloc.activeChannelStream,
      builder: (BuildContext context,
          AsyncSnapshot<IRCNetworkChannel> activeChannelSnapshot) {
        var activeChannel = activeChannelSnapshot.data;
        if (activeChannel == null) {
          return Text(AppLocalizations.of(context).tr('chat.title'));
        } else {
          return Provider<IRCNetworkChannelBloc>(
              bloc: IRCNetworkChannelBloc(lounge, activeChannel),
              child: IRCNetworkChannelTopicTitleWidget());
        }
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    var activeChannelBloc = Provider.of<IRCChatActiveChannelBloc>(context);
    var lounge = Provider.of<LoungeService>(context);
    return SafeArea(
        child: StreamBuilder<IRCNetworkChannel>(
            stream: activeChannelBloc.activeChannelStream,
            builder: (BuildContext context,
                AsyncSnapshot<IRCNetworkChannel> snapshot) {
              var channel = snapshot.data;
              if (channel == null) {
                var networksListBloc = Provider.of<ChatBloc>(context);
                return StreamBuilder<bool>(
                  stream: networksListBloc.networksIsEmptyStream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    var isEmpty = snapshot.data;
                    if (isEmpty) {
                      return Text(AppLocalizations.of(context)
                          .tr("irc_connection.no_networks"));
                    } else {
                      return Text(AppLocalizations.of(context)
                          .tr('chat.no_active_channel'));
                    }
                  },
                );
              } else {
                return Provider<IRCNetworkChannelBloc>(
                    bloc: IRCNetworkChannelBloc(lounge, channel),
                    child: IRCNetworkChannelWidget(channel));
              }
            }));
  }
}
