import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_chat_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_topic_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_widget.dart';
import 'package:flutter_appirc/widgets/irc_networks_list_widget.dart';

class IRCChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var chatBloc = Provider.of<IRCChatBloc>(context);
    var lounge = Provider.of<LoungeService>(context);
    return Scaffold(
        appBar: AppBar(
          title: StreamBuilder<IRCNetworkChannel>(
            stream: chatBloc.activeChannelStream,
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
          ),
        ),
        body: Center(child: IRCNetworkChannelWidget()),
        drawer: Drawer(child: IRCNetworksListWidget()));
  }
}
