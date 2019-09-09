import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_chat_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_messages_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_new_message_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_topic_bloc.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkChannelTopicTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = Provider.of<IRCNetworkChannelBloc>(context);
    var lounge = Provider.of<LoungeService>(context);
    var topicBloc = IRCNetworkChannelTopicBloc(lounge, channelBloc.channel);

    return StreamBuilder<String>(
      stream: topicBloc.outTopic,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        var topic = snapshot.data;
        var channelName = topicBloc.channel.name;
        if (topic == null || topic.isEmpty) {
          return Text(channelName);
        } else {
          var captionStyle = Theme.of(context).textTheme.caption;
          var topicStyle = captionStyle.copyWith(color: Colors.white);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(channelName),
              Text(topic, style: topicStyle)
            ],
          );
        }
      },
    );
  }
}
