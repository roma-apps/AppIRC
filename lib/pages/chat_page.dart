import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/channel_bloc.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/widgets/channel_widget.dart';
import 'package:flutter_appirc/widgets/channels_list_widget.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: StreamBuilder<Channel>(
            stream: chatBloc.outActiveChannel,
            builder: (BuildContext context, AsyncSnapshot<Channel> activeChannelSnapshot) {
              var activeChannel = activeChannelSnapshot.data;
              if (activeChannel == null) {
                return Text(AppLocalizations.of(context).tr('chat.title'));
              } else {
                var topicBloc = ChannelTopicBloc(chatBloc.lounge, activeChannel);
                return Provider(
                  bloc: topicBloc,
                  child: TopicTitleWidget(),
                );
              }
            },
          ),
        ),
        body: Center(child: ChannelWidget()),
        drawer: Drawer(child: ChannelsListWidget()));
  }
}
