import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, AppBar, Drawer;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_chat_active_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_networks_list_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/pages/irc_network_channel_users_page.dart';
import 'package:flutter_appirc/pages/irc_chat_settings_page.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/irc_chat_settings_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_topic_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_widget.dart';
import 'package:flutter_appirc/widgets/irc_networks_list_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);
    var networksListBloc = Provider.of<IRCNetworksListBloc>(context);
    return Provider<IRCChatActiveChannelBloc>(
    bloc: IRCChatActiveChannelBloc(lounge, networksListBloc: networksListBloc),
    child: PlatformScaffold(
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
            ))),
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
                return Text(
                    AppLocalizations.of(context).tr("chat.no_active_channel"));
              } else {
                return Provider<IRCNetworkChannelBloc>(
                    bloc: IRCNetworkChannelBloc(lounge, channel),
                    child: IRCNetworkChannelWidget(channel));
              }
            }));
  }
}